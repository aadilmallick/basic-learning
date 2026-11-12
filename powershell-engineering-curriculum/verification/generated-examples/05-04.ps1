# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-LeadingRedCount {
    [CmdletBinding()]
    param([object[]]$NewestFirstBuilds = @())
    $count = 0
    foreach ($build in $NewestFirstBuilds) {
        if ([string]$build.Status -notin @('FAILURE', 'ERROR')) { break }
        $count++
    }
    $count
}
$history = @(
    [pscustomobject]@{ Status = 'FAILURE' }
    [pscustomobject]@{ Status = 'ERROR' }
    [pscustomobject]@{ Status = 'SUCCESS' }
    [pscustomobject]@{ Status = 'FAILURE' }
)
Get-LeadingRedCount -NewestFirstBuilds $history

