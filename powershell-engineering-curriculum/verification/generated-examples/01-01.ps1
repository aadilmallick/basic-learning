# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$name = 'Backend build'
$count = 42
$build = [pscustomobject]@{
    Id = '1001'
    Number = '2026.11.12.1'
    Status = 'FAILURE'
}
$name.GetType().FullName
$count.GetType().FullName
$build.Status
$build.Status.ToLowerInvariant()
$build | Get-Member -MemberType NoteProperty

