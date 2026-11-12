# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class ValidatedScanOptions {
    [ValidateRange(1, 500)]
    [int]$MaximumBuilds = 100

    ValidatedScanOptions([int]$maximumBuilds) {
        $this.MaximumBuilds = $maximumBuilds
    }
}
$options = [ValidatedScanOptions]::new(25)
$options.MaximumBuilds = 50
$options.MaximumBuilds
try { $options.MaximumBuilds = 0 }
catch { 'Rejected an out-of-range assignment' }
$options.MaximumBuilds

