# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$missing = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.missing')
try {
    Get-Item -LiteralPath $missing -ErrorAction Stop
}
catch {
    [pscustomobject]@{
        ExceptionType = $_.Exception.GetType().FullName
        Category = $_.CategoryInfo.Category
        ErrorId = $_.FullyQualifiedErrorId
    }
}

