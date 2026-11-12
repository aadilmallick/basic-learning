# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class ScanIdentity {
    static [int]$Created = 0
    [string]$Name
    ScanIdentity([string]$name) {
        $this.Name = $name
        [ScanIdentity]::Created++
    }
}
$first = [ScanIdentity]::new('morning')
$second = [ScanIdentity]::new('evening')
$first.Name
$second.Name
[ScanIdentity]::Created

