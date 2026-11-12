# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$result = [pscustomobject]@{
    Health = 'RED'
    OldestObservedRedAt = [DateTimeOffset]::Parse('2026-11-10T14:00:00Z')
    BoundaryObserved = $false
    ObservedRedCount = 100
}
$prefix = if ($result.BoundaryObserved) { 'Observed streak begins at ' } else { 'At least since ' }
$prefix + $result.OldestObservedRedAt.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')

