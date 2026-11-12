# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-BuildId {
    param([int]$Count)
    for ($index = 1; $index -le $Count; $index++) {
        "build-$index"
    }
}
$none = @(Get-BuildId -Count 0)
$one = @(Get-BuildId -Count 1)
$many = @(Get-BuildId -Count 3)
"Counts: $($none.Count), $($one.Count), $($many.Count)"

