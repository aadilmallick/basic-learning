# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$entry = Join-Path (Get-Location) 'examples/ReferenceImplementation/New-TeamCityHealthReport.ps1'
$result = & $entry -Offline
$result.WrittenPaths
$result.Scan | Select-Object Listed, Excluded, Eligible, IsComplete
$result.Scan.Rows | Select-Object PipelineId, Health, ObservedRedCount, BoundaryObserved

