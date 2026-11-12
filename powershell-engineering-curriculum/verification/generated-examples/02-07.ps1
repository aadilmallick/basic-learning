# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function New-TeamCityQueryDescription {
    [CmdletBinding()]
    param([string]$BuildTypeId = 'Backend_Build', [int]$Count = 10)
    $query = @{ BuildTypeId = $BuildTypeId; Count = $Count }
    [pscustomobject]@{
        Id = $query.BuildTypeId
        Count = $query.Count
        CountWasExplicit = $PSBoundParameters.ContainsKey('Count')
    }
}
New-TeamCityQueryDescription
New-TeamCityQueryDescription -Count 10

