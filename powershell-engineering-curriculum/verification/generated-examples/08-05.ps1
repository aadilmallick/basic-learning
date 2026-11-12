# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$rows = @(
    [pscustomobject]@{ ProjectId = 'B'; Name = 'Build'; Health = 'RED' }
    [pscustomobject]@{ ProjectId = 'A'; Name = 'Build'; Health = 'GREEN' }
)
$ordered = @($rows | Sort-Object ProjectId, Name)
$red = @($ordered | Where-Object Health -eq RED).Count
$percent = 100.0 * $red / $ordered.Count
$cssValue = $percent.ToString('0.###', [Globalization.CultureInfo]::InvariantCulture)
$ordered | Select-Object ProjectId, Name
"CSS percentage: $cssValue"

