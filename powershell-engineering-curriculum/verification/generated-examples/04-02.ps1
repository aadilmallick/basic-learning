# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class ScanWindow {
    [int]$MaximumBuilds

    ScanWindow() {
        $this.MaximumBuilds = 100
    }

    ScanWindow([int]$maximumBuilds) {
        if ($maximumBuilds -lt 1 -or $maximumBuilds -gt 500) {
            throw [ArgumentOutOfRangeException]::new('maximumBuilds')
        }
        $this.MaximumBuilds = $maximumBuilds
    }

    [string] Describe() {
        return "Inspect up to $($this.MaximumBuilds) recent builds"
    }
}
[ScanWindow]::new().Describe()
[ScanWindow]::new(25).Describe()

