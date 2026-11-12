# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function New-RestRoot {
    param([Parameter(Mandatory)][uri]$Server)
    if (-not $Server.IsAbsoluteUri -or $Server.Scheme -ne 'https') {
        throw 'Use an absolute HTTPS server URI.'
    }
    if ($Server.UserInfo -or $Server.Query -or $Server.Fragment) {
        throw 'Server URI must not contain credentials, query, or fragment.'
    }
    $builder = [UriBuilder]::new($Server)
    $path = $builder.Path.TrimEnd('/')
    if (-not $path.EndsWith('/app/rest', [StringComparison]::OrdinalIgnoreCase)) {
        $path += '/app/rest'
    }
    $builder.Path = "$path/"
    $builder.Uri
}
New-RestRoot -Server 'https://ci.example.com/teamcity/'
New-RestRoot -Server 'https://ci.example.com/teamcity/app/rest/'

