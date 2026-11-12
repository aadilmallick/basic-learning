# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-RequiredCollection {
    param([Parameter(Mandatory)][psobject]$Response, [string]$Name)
    $property = $Response.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        throw "Response does not contain the required '$Name' collection."
    }
    foreach ($item in @($property.Value)) { $item }
}
$emptyResponse = [pscustomobject]@{ build = @() }
"Valid empty count: $(@(Get-RequiredCollection -Response $emptyResponse -Name build).Count)"
try {
    Get-RequiredCollection -Response ([pscustomobject]@{ message = 'unexpected' }) -Name build
}
catch { 'Rejected an incompatible response shape' }

