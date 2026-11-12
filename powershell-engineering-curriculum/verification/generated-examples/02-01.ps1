# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-TeamCityBuildLabel {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BuildTypeId,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int]$BuildNumber,

        [switch]$IncludeStatus
    )
    Write-Verbose "Creating label for $BuildTypeId"
    $label = '{0} #{1}' -f $BuildTypeId, $BuildNumber
    if ($IncludeStatus) { $label += ' [status unavailable]' }
    $label
}
Get-TeamCityBuildLabel -BuildTypeId Backend_Build -BuildNumber 12 -Verbose

