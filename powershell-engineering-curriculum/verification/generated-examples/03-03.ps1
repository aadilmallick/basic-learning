# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$stream = [IO.MemoryStream]::new()
try {
    $bytes = [Text.Encoding]::UTF8.GetBytes('TeamCity report')
    $stream.Write($bytes, 0, $bytes.Length)
    "Bytes written: $($stream.Length)"
}
finally {
    $stream.Dispose()
}
"Can write after disposal: $($stream.CanWrite)"

