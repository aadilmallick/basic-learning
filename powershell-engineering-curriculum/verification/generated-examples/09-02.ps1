# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$buildTypeId = 'Backend_Build'
if ($buildTypeId -notmatch '^[A-Za-z0-9_-]+$') {
    throw 'This example accepts only simple TeamCity external IDs.'
}
$query = [ordered]@{
    locator = "buildType:(id:$buildTypeId),state:finished,personal:false,canceled:false,defaultFilter:false,count:100"
    fields = 'nextHref,build(id,number,status,finishDate,webUrl)'
}
$parts = foreach ($key in $query.Keys) {
    '{0}={1}' -f [uri]::EscapeDataString($key), [uri]::EscapeDataString($query[$key])
}
'https://ci.example.com/app/rest/builds?' + ($parts -join '&')

