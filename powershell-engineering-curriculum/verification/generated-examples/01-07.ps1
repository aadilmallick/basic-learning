# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Set-StrictMode -Version Latest
$response = [pscustomobject]@{ build = @() }
$property = $response.PSObject.Properties['build']
if ($null -eq $property) {
    throw 'Response is missing the build collection'
}
$builds = @($property.Value)
"Build count: $($builds.Count)"
$optional = $response.PSObject.Properties['nextHref']
if ($null -eq $optional) { 'No continuation property' }

