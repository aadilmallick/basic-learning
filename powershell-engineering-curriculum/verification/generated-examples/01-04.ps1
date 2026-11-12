# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-FailedBuildCount {
    [CmdletBinding()]
    param([object[]]$Build = @())
    Write-Verbose "Inspecting $($Build.Count) builds"
    $failed = @($Build | Where-Object Status -in @('FAILURE', 'ERROR'))
    return $failed.Count
}
$inputBuilds = @(
    [pscustomobject]@{ Status = 'FAILURE' }
    [pscustomobject]@{ Status = 'SUCCESS' }
)
$result = Get-FailedBuildCount -Build $inputBuilds -Verbose
"Result type: $($result.GetType().Name); count: $result"

