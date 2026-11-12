# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Measure-TeamCityHealth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]$InputObject
    )
    begin { $total = 0; $red = 0 }
    process {
        $total++
        if ($InputObject.Status -in @('FAILURE', 'ERROR')) { $red++ }
    }
    end {
        [pscustomobject]@{
            Total = $total
            Red = $red
            RedPercent = if ($total) { 100.0 * $red / $total } else { 0.0 }
        }
    }
}
@(
    [pscustomobject]@{ Status = 'SUCCESS' }
    [pscustomobject]@{ Status = 'FAILURE' }
) | Measure-TeamCityHealth

