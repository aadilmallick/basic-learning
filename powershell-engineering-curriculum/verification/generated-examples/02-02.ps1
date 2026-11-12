# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function New-TeamCityEndpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [uri]$Server,
        [ValidateRange(1, 1000)]
        [int]$PageSize = 100
    )
    if (-not $Server.IsAbsoluteUri -or $Server.Scheme -ne 'https') {
        throw 'Server must be an absolute HTTPS URI.'
    }
    if ($Server.UserInfo -or $Server.Query -or $Server.Fragment) {
        throw 'Server must not contain credentials, query, or fragment.'
    }
    [pscustomobject]@{
        Server = $Server
        PageSize = $PageSize
    }
}
New-TeamCityEndpoint -Server 'https://ci.example.com/teamcity/'

