# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Measure-ConfigurationBatch {
    <#
    .SYNOPSIS
    Counts configurations in one explicitly supplied batch.
    .DESCRIPTION
    An empty batch is valid and returns a count of zero. Null elements are rejected.
    This function performs no discovery and makes no network requests.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Configuration
    )
    foreach ($item in $Configuration) {
        if ($null -eq $item) { throw 'A configuration element must not be null.' }
    }
    [pscustomobject]@{ Count = $Configuration.Count }
}
Measure-ConfigurationBatch -Configuration @()

