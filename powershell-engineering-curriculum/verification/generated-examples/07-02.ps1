# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$utility = Get-Module -ListAvailable Microsoft.PowerShell.Utility |
    Sort-Object Version -Descending |
    Select-Object -First 1
Import-Module $utility.Path -ErrorAction Stop
Get-Command ConvertTo-Json | Select-Object Name, ModuleName
Get-Module Microsoft.PowerShell.Utility | Select-Object Name, Version

