# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$instant = [DateTimeOffset]::ParseExact(
    '20261112T090000-05:00',
    "yyyyMMdd'T'HHmmsszzz",
    [Globalization.CultureInfo]::InvariantCulture
)
$instant.ToUniversalTime().ToString('O')
[Net.WebUtility]::HtmlEncode('<Backend & API>')
[uri]::EscapeDataString('buildType:(id:Backend_Build),count:100')
$builder = [Text.StringBuilder]::new()
[void]$builder.AppendLine('<h1>Pipeline health</h1>')
[void]$builder.AppendLine('<p>Example</p>')
$builder.ToString()

