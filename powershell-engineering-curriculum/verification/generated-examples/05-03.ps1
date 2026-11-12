# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class OwnedReportBuffer : System.IDisposable {
    hidden [IO.MemoryStream]$stream
    [bool]$IsDisposed

    OwnedReportBuffer() {
        $this.stream = [IO.MemoryStream]::new()
        $this.IsDisposed = $false
    }

    [void] WriteText([string]$text) {
        if ($this.IsDisposed) { throw [ObjectDisposedException]::new('OwnedReportBuffer') }
        $bytes = [Text.Encoding]::UTF8.GetBytes($text)
        $this.stream.Write($bytes, 0, $bytes.Length)
    }

    [void] Dispose() {
        if (-not $this.IsDisposed) {
            $this.stream.Dispose()
            $this.IsDisposed = $true
        }
    }
}
$buffer = [OwnedReportBuffer]::new()
try { $buffer.WriteText('<p>Health</p>') }
finally { $buffer.Dispose() }
$buffer.IsDisposed

