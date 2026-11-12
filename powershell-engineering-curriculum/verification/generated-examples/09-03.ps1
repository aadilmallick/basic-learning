# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$pages = @{
    first = [pscustomobject]@{
        buildType = @([pscustomobject]@{ id = 'A' })
        nextHref = 'second'
    }
    second = [pscustomobject]@{
        buildType = @([pscustomobject]@{ id = 'B' })
        nextHref = ''
    }
}
$seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$next = 'first'
while ($next) {
    if (-not $seen.Add($next)) { throw 'Repeated continuation detected.' }
    $page = $pages[$next]
    foreach ($item in @($page.buildType)) { $item.id }
    $next = [string]$page.nextHref
}

