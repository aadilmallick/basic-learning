# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Export-PreviewText {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Path, [string]$Text)
    if ($PSCmdlet.ShouldProcess($Path, 'Write text')) {
        [IO.File]::WriteAllText($Path, $Text)
    }
}
$path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.txt')
Export-PreviewText -Path $path -Text 'example' -WhatIf
if (Test-Path -LiteralPath $path) { throw 'Preview unexpectedly wrote a file.' }
'Preview left no artifact'

