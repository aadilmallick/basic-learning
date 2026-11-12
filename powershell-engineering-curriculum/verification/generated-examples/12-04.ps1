# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$entry = './examples/ReferenceImplementation/New-TeamCityHealthReport.ps1'
$previewDirectory = Join-Path ([IO.Path]::GetTempPath()) ('ReportPreview-' + [guid]::NewGuid())
$preview = & $entry -Offline -OutputDirectory $previewDirectory -WhatIf
$preview.Preview
Test-Path -LiteralPath $previewDirectory

