# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Find-TeamCityConfiguration {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$Id,
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name,
        [switch]$IncludeArchived
    )
    [pscustomobject]@{
        Selector = $PSCmdlet.ParameterSetName
        Value = if ($PSCmdlet.ParameterSetName -eq 'ById') { $Id } else { $Name }
        IncludeArchived = $IncludeArchived.IsPresent
    }
}
Find-TeamCityConfiguration -Id 'Backend_Build'
Find-TeamCityConfiguration -Name 'Build backend' -IncludeArchived

