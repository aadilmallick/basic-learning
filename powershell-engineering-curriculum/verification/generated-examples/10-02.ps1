# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Import-Module './examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psd1' -Force
$history = @(
    [pscustomobject]@{ Status = 'FAILURE'; FinishedAt = $null }
    [pscustomobject]@{ Status = 'SUCCESS'; FinishedAt = $null }
)
$before = @($history | ForEach-Object Status) -join ','
$result = Get-PipelineHealth -NewestFirstBuilds $history
$after = @($history | ForEach-Object Status) -join ','
if ($before -cne $after) { throw 'Analyzer mutated its input.' }
if ($result.ObservedRedCount -gt $result.ObservedBuildCount) { throw 'Invalid streak count.' }
'Input and count invariants held'

