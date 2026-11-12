#requires -Version 7.4
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'The only literal is a fixed offline fixture placeholder, never a live credential.')]
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param(
    [switch]$Offline,
    [uri]$Server,
    [securestring]$Token,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output'),
    [ValidateRange(1,500)][int]$MaxBuildsToScan = 100,
    [string[]]$ExcludeProjectName = @(),
    [string[]]$ExcludePipelineName = @()
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
foreach ($moduleName in @('TeamCityAPI','PipelineHealth','HTMLArtifact')) {
    Import-Module (Join-Path $PSScriptRoot "$moduleName/$moduleName.psd1") -Force -ErrorAction Stop
}
if ($Offline) {
    $fixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures.json') -Raw | ConvertFrom-Json
    $Server = [uri]'https://ci.example.com/teamcity/'
    $Token = ConvertTo-SecureString 'offline-placeholder' -AsPlainText -Force
    $transport = {
        param($uri, $token)
        if ($null -eq $token) { throw 'Fixture transport requires the standard token argument.' }
        if ($uri.AbsolutePath.EndsWith('/buildTypes')) {
            return [pscustomobject]@{ buildType = @($fixture.configurations); nextHref = '' }
        }
        if ($uri.AbsolutePath.EndsWith('/builds')) {
            $queryText = [uri]::UnescapeDataString($uri.Query)
            if ($queryText -notmatch 'buildType:\(id:([A-Za-z0-9_-]+)\)') { throw 'Fixture locator not recognized.' }
            $id = $Matches[1]
            if ($id -eq 'Unavailable_Build') { throw 'Simulated unavailable history.' }
            $history = $fixture.histories.PSObject.Properties[$id]
            if ($null -eq $history) { throw 'Fixture history not found.' }
            return [pscustomobject]@{ build = @($history.Value); nextHref = '' }
        }
        if ($uri.AbsolutePath -match '/projects/id:([A-Za-z0-9_-]+)$') {
            $property = $fixture.projects.PSObject.Properties[$Matches[1]]
            if ($null -eq $property) { throw 'Fixture project not found.' }
            return $property.Value
        }
        throw 'Unexpected fixture request.'
    }.GetNewClosure()
    $client = New-TeamCityClient -Server $Server -Token $Token -Transport $transport
}
else {
    if ($null -eq $Server -or $null -eq $Token) { throw 'Live use requires -Server and -Token.' }
    $client = New-TeamCityClient -Server $Server -Token $Token
}

function Test-ExcludedName {
    param([string]$Name, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if (-not [string]::IsNullOrWhiteSpace($pattern) -and $Name -like $pattern) { return $true }
    }
    $false
}

$generatedAt = if ($Offline) { [DateTimeOffset]::Parse('2026-11-12T14:00:00Z') } else { [DateTimeOffset]::UtcNow }
$configurations = @(Get-TeamCityBuildType -Client $client)
$rows = [Collections.Generic.List[object]]::new()
$failures = [Collections.Generic.List[object]]::new()
$excluded = 0
$groupingFallbacks = 0
foreach ($configuration in $configurations) {
    if ((Test-ExcludedName $configuration.projectName $ExcludeProjectName) -or
        (Test-ExcludedName $configuration.name $ExcludePipelineName)) {
        $excluded++
        continue
    }
    try {
        $history = @(Get-TeamCityBuildHistory -Client $client -BuildTypeId $configuration.id -Limit $MaxBuildsToScan)
        $health = Get-PipelineHealth -NewestFirstBuilds $history
        try {
            $top = Resolve-TeamCityTopProject -Client $client -ProjectId $configuration.projectId
        }
        catch {
            $groupingFallbacks++
            $top = [pscustomobject]@{ Id = [string]$configuration.projectId; Name = [string]$configuration.projectName }
        }
        $rows.Add([pscustomobject]@{
            PipelineId = [string]$configuration.id
            PipelineName = [string]$configuration.name
            PipelineUrl = [string]$configuration.webUrl
            ProjectId = [string]$configuration.projectId
            ProjectName = [string]$configuration.projectName
            TopLevelProjectId = $top.Id
            TopLevelProjectName = $top.Name
            Health = $health.Health
            LatestStatus = $health.LatestStatus
            LatestAt = $health.LatestAt
            OldestObservedRedAt = $health.OldestObservedRedAt
            BoundaryObserved = $health.BoundaryObserved
            ObservedRedCount = $health.ObservedRedCount
            ObservedBuildCount = $health.ObservedBuildCount
        })
    }
    catch {
        # Publish a safe summary; do not copy arbitrary external exception text into an artifact.
        $failures.Add([pscustomobject]@{ Id = [string]$configuration.id; Reason = 'History or analysis unavailable' })
        Write-Verbose "Inspection failed for configuration '$($configuration.id)'."
    }
}
$scan = [pscustomobject]@{
    GeneratedAt = $generatedAt
    Server = $Server.AbsoluteUri
    Scope = "Finished, nonpersonal, noncanceled builds; defaultFilter:false; no explicit branch selector; up to $MaxBuildsToScan observations per configuration"
    Listed = $configurations.Count
    Excluded = $excluded
    Eligible = $configurations.Count - $excluded
    Rows = $rows.ToArray()
    Failures = $failures.ToArray()
    GroupingFallbacks = $groupingFallbacks
    IsComplete = ($failures.Count -eq 0)
}
if ($scan.Eligible -ne $scan.Rows.Count + $scan.Failures.Count) { throw 'Scan accounting invariant failed.' }
$htmlByView = @{}
foreach ($view in @('Red','Summary','Projects')) {
    $htmlByView[$view] = ConvertTo-PipelineReportHtml -Scan $scan -View $view
}
$resolvedDirectory = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
if (-not (Test-Path -LiteralPath $resolvedDirectory) -and
    $PSCmdlet.ShouldProcess($resolvedDirectory, 'Create report directory')) {
    $null = New-Item -ItemType Directory -Path $resolvedDirectory
}
$written = [Collections.Generic.List[string]]::new()
foreach ($view in @('Red','Summary','Projects')) {
    $destination = Join-Path $resolvedDirectory "$view.html"
    if ($PSCmdlet.ShouldProcess($destination, 'Write rendered report')) {
        $file = Export-HtmlArtifact -LiteralPath $destination -Html $htmlByView[$view] -Confirm:$false
        $written.Add($file.FullName)
    }
}
[pscustomobject]@{ Scan = $scan; WrittenPaths = $written.ToArray(); Preview = [bool]$WhatIfPreference }
