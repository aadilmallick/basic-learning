# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$statuses = @('SUCCESS', 'FAILURE', 'ERROR', 'UNKNOWN') * 1000
$measurement = Measure-Command {
    $red = 0
    foreach ($status in $statuses) {
        if ($status -in @('FAILURE', 'ERROR')) { $red++ }
    }
}
[pscustomobject]@{ Red = $red; Milliseconds = $measurement.TotalMilliseconds }

