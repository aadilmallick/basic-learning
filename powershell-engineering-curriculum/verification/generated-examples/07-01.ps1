# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$moduleDirectory = Join-Path ([IO.Path]::GetTempPath()) ('CurriculumModule-' + [guid]::NewGuid())
$null = New-Item -ItemType Directory -Path $moduleDirectory
$modulePath = Join-Path $moduleDirectory 'HealthLabels.psm1'
@'
function ConvertTo-HealthLabel {
    [CmdletBinding()]
    param([string]$Status)
    switch ($Status.ToUpperInvariant()) {
        'SUCCESS' { 'GREEN'; break }
        'FAILURE' { 'RED'; break }
        default { 'OTHER' }
    }
}
function Get-InternalPalette { '#c5282f' }
Export-ModuleMember -Function ConvertTo-HealthLabel
'@ | Set-Content -LiteralPath $modulePath -Encoding utf8
try {
    Import-Module $modulePath -Force
    ConvertTo-HealthLabel -Status FAILURE
    @(Get-Command Get-InternalPalette -ErrorAction SilentlyContinue).Count
}
finally {
    Remove-Module HealthLabels -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $modulePath
    Remove-Item -LiteralPath $moduleDirectory
}

