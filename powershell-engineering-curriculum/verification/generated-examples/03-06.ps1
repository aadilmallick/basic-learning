# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.temporary')
$stream = $null
try {
    $stream = [IO.File]::Open($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
    $stream.WriteByte(65)
    throw [InvalidOperationException]::new('Simulated render failure')
}
catch {
    "Handled: $($_.Exception.Message)"
}
finally {
    if ($null -ne $stream) { $stream.Dispose() }
    if ([IO.File]::Exists($path)) { [IO.File]::Delete($path) }
}
"Temporary file exists: $([IO.File]::Exists($path))"

