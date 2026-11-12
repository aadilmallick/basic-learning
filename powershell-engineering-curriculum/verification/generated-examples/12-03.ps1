# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Import-Module './examples/ReferenceImplementation/TeamCityAPI/TeamCityAPI.psd1' -Force
$observed = [Collections.Generic.List[string]]::new()
$transport = {
    param($uri, $token)
    $observed.Add($uri.AbsoluteUri)
    [pscustomobject]@{ buildType = @(); nextHref = '' }
}.GetNewClosure()
$token = ConvertTo-SecureString 'fixture-only' -AsPlainText -Force
$client = New-TeamCityClient -Server 'https://ci.example.com/teamcity/' -Token $token -Transport $transport
$items = @(Get-TeamCityBuildType -Client $client -PageSize 25)
"Items: $($items.Count)"
$observed

