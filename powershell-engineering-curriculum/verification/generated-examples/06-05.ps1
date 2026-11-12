# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$json = '{"id":1001,"status":"FAILURE","finishDate":"20261112T140000+0000"}'
$dto = $json | ConvertFrom-Json
$dateText = $dto.finishDate -replace '([+-]\d{2})(\d{2})$', '$1:$2'
$finishedAt = [DateTimeOffset]::ParseExact(
    $dateText,
    "yyyyMMdd'T'HHmmsszzz",
    [Globalization.CultureInfo]::InvariantCulture
)
[pscustomobject]@{
    Id = [string]$dto.id
    RawStatus = [string]$dto.status
    FinishedAt = $finishedAt
}

