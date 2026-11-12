# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$root = [uri]'https://ci.example.com/teamcity/app/rest/'
$current = [uri]'https://ci.example.com/teamcity/app/rest/buildTypes?locator=count%3A100'
$next = [uri]::new($current, '/teamcity/app/rest/buildTypes?locator=start%3A100')
$sameOrigin = $next.Scheme -eq $root.Scheme -and
    $next.IdnHost -eq $root.IdnHost -and $next.Port -eq $root.Port
$insideRest = $next.AbsolutePath.StartsWith($root.AbsolutePath, [StringComparison]::Ordinal)
if (-not $sameOrigin -or -not $insideRest -or $next.UserInfo -or $next.Fragment) {
    throw 'Continuation is outside the approved REST boundary.'
}
$next.AbsoluteUri

