# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class ArtifactDescription {
    [string]$Name
    ArtifactDescription([string]$name) { $this.Name = $name }
    [string] GetMediaType() { return 'application/octet-stream' }
}
class HtmlArtifactDescription : ArtifactDescription {
    HtmlArtifactDescription([string]$name) : base($name) { }
    [string] GetMediaType() { return 'text/html' }
}
$artifacts = @(
    [ArtifactDescription]::new('raw-data')
    [HtmlArtifactDescription]::new('health-report')
)
foreach ($artifact in $artifacts) {
    '{0}: {1}' -f $artifact.Name, $artifact.GetMediaType()
}

