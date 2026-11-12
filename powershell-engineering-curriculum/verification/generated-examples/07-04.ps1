# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$path = './examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psd1'
$data = Import-PowerShellDataFile -LiteralPath $path
$data.RootModule
$data.ModuleVersion
$data.FunctionsToExport
$module = Test-ModuleManifest -Path $path -ErrorAction Stop
$module.Name

