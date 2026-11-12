# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$builds = @(
    [pscustomobject]@{ Id = '101'; Status = 'SUCCESS'; Duration = 12 }
    [pscustomobject]@{ Id = '102'; Status = 'FAILURE'; Duration = 30 }
    [pscustomobject]@{ Id = '103'; Status = 'FAILURE'; Duration = 20 }
)
$failed = @($builds | Where-Object Status -eq 'FAILURE')
$failed |
    Sort-Object Duration -Descending |
    Select-Object Id, Duration

