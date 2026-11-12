# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$raw = '20261112T090000-0500'
$normalized = $raw -replace '([+-]\d{2})(\d{2})$', '$1:$2'
$instant = [DateTimeOffset]::ParseExact(
    $normalized,
    "yyyyMMdd'T'HHmmsszzz",
    [Globalization.CultureInfo]::InvariantCulture
)
$instant.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')

