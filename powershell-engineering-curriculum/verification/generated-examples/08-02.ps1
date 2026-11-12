# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-ConfigurationSnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$Id,
        [Parameter(Mandatory)][scriptblock]$ReadHistory,
        [Parameter(Mandatory)][DateTimeOffset]$GeneratedAt
    )
    foreach ($configurationId in $Id) {
        $history = @(& $ReadHistory $configurationId)
        [pscustomobject]@{
            Id = $configurationId
            GeneratedAt = $GeneratedAt
            LatestStatus = if ($history.Count) { $history[0].Status } else { 'NO_BUILDS' }
        }
    }
}
$fixture = {
    param($configurationId)
    [pscustomobject]@{ Status = 'SUCCESS'; Id = "$configurationId-101" }
}
Get-ConfigurationSnapshot -Id Backend_Build,Frontend_Build -ReadHistory $fixture -GeneratedAt (
    [DateTimeOffset]::Parse('2026-11-12T14:00:00Z')
)

