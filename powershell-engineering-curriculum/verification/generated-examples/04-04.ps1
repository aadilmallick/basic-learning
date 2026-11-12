# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$original = [pscustomobject]@{
    Name = 'Backend'
    Tags = [Collections.Generic.List[string]]::new()
}
$alias = $original
$alias.Name = 'Changed'
$alias.Tags.Add('red')
$original.Name
$original.Tags.Count

$snapshot = [pscustomobject]@{
    Name = $original.Name
    Tags = @($original.Tags.ToArray())
}
$original.Tags.Add('urgent')
$snapshot.Tags.Count

