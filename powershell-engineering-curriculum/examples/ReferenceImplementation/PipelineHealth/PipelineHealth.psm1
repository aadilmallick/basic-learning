Set-StrictMode -Version Latest

function Get-PipelineHealth {
    <#
    .SYNOPSIS
    Interprets current health and the leading red prefix of ordered observations.
    .PARAMETER NewestFirstBuilds
    Normalized objects with Status and FinishedAt, newest first in the chosen
    source order. FinishedAt may be null. FAILURE and ERROR are red; every other
    status ends a red prefix. Empty input means OTHER / NO_BUILDS.
    .OUTPUTS
    PSCustomObject with classification, observed counts, instants, and boundary evidence.
    #>
    [CmdletBinding()]
    param([AllowEmptyCollection()][object[]]$NewestFirstBuilds = @())
    $latestStatus = 'NO_BUILDS'
    $health = 'OTHER'
    $latestAt = $null
    $oldestRedAt = $null
    $boundaryObserved = $false
    $redCount = 0
    foreach ($build in $NewestFirstBuilds) {
        if ($null -eq $build -or [string]::IsNullOrWhiteSpace([string]$build.Status)) {
            throw 'Every observation must have a usable status.'
        }
    }
    if ($NewestFirstBuilds.Count -gt 0) {
        $latestStatus = ([string]$NewestFirstBuilds[0].Status).ToUpperInvariant()
        $latestAt = $NewestFirstBuilds[0].FinishedAt
        $health = if ($latestStatus -eq 'SUCCESS') { 'GREEN' }
                  elseif ($latestStatus -in @('FAILURE','ERROR')) { 'RED' }
                  else { 'OTHER' }
        if ($health -eq 'RED') {
            foreach ($build in $NewestFirstBuilds) {
                if ([string]$build.Status -notin @('FAILURE','ERROR')) {
                    $boundaryObserved = $true
                    break
                }
                $redCount++
                $oldestRedAt = $build.FinishedAt
            }
        }
    }
    [pscustomobject]@{
        Health = $health
        LatestStatus = $latestStatus
        LatestAt = $latestAt
        ObservedRedCount = $redCount
        OldestObservedRedAt = $oldestRedAt
        BoundaryObserved = $boundaryObserved
        ObservedBuildCount = $NewestFirstBuilds.Count
    }
}

function Get-HealthSummary {
    <#
    .SYNOPSIS
    Counts GREEN, RED, and OTHER rows without changing them.
    .PARAMETER Rows
    Inspected health results. Empty input is valid; unknown classifications fail.
    .OUTPUTS
    PSCustomObject with Total, Green, Red, and Other counts.
    #>
    [CmdletBinding()]
    param([AllowEmptyCollection()][object[]]$Rows = @())
    $green = @($Rows | Where-Object Health -eq 'GREEN').Count
    $red = @($Rows | Where-Object Health -eq 'RED').Count
    $other = @($Rows | Where-Object Health -eq 'OTHER').Count
    if ($green + $red + $other -ne $Rows.Count) { throw 'Unrecognized health classification.' }
    [pscustomobject]@{ Total = $Rows.Count; Green = $green; Red = $red; Other = $other }
}
Export-ModuleMember -Function Get-PipelineHealth, Get-HealthSummary
