# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-NoObservation { return }
$empty = @(Get-NoObservation)
$nullSlot = @($null)
$envelope = [pscustomobject]@{ Rows = @(); Complete = $true }
"Empty output: $($empty.Count)"
"Explicit null slot: $($nullSlot.Count)"
"Envelope rows: $($envelope.Rows.Count)"
$lookup = @{ Backend = 'RED'; Frontend = 'GREEN' }
@($lookup.GetEnumerator() | Sort-Object Key) |
    Select-Object Key, Value

