# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$server = 'outer'
$settings = @{ Server = 'original' }
function Set-LocalExample {
    $server = 'inner'
    $settings.Server = 'changed'
}
Set-LocalExample
$server
$settings.Server

function New-ReportLabel {
    param([string]$Server, [int]$BuildCount)
    "$Server has $BuildCount builds"
}
New-ReportLabel -Server 'ci.example.com' -BuildCount 3

