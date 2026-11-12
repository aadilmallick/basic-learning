# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$ids = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
[void]$ids.Add('Backend_Build')
[void]$ids.Add('Backend_Build')
[void]$ids.Add('backend_build')
$ids.Count

$cache = [Collections.Generic.Dictionary[string, object]]::new(
    [StringComparer]::Ordinal
)
$cache['ProjectA'] = [pscustomobject]@{ Name = 'Backend' }
$value = $null
if ($cache.TryGetValue('ProjectA', [ref]$value)) { $value.Name }

