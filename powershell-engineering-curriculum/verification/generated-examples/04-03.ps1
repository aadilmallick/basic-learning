# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class ReportCounter {
    hidden [int]$redCount

    ReportCounter() { $this.redCount = 0 }

    [void] RecordRedBuild() {
        $this.redCount++
    }

    [int] GetRedCount() {
        return $this.redCount
    }
}
$counter = [ReportCounter]::new()
$counter.RecordRedBuild()
$counter.RecordRedBuild()
$counter.GetRedCount()
$counter.redCount = -5
$counter.GetRedCount()

