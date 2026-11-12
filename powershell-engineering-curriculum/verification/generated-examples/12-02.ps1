# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Import-Module './examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psd1' -Force
$history = @(
    [pscustomobject]@{ Status = 'FAILURE'; FinishedAt = [DateTimeOffset]::Parse('2026-11-12T14:00:00Z') }
    [pscustomobject]@{ Status = 'ERROR'; FinishedAt = [DateTimeOffset]::Parse('2026-11-11T14:00:00Z') }
    [pscustomobject]@{ Status = 'SUCCESS'; FinishedAt = [DateTimeOffset]::Parse('2026-11-10T14:00:00Z') }
)
$health = Get-PipelineHealth -NewestFirstBuilds $history
$health | Format-List

