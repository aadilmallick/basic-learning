# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-TeamCityConfigurationKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [ValidateNotNullOrEmpty()]
        [string]$BuildTypeId
    )
    process {
        [pscustomobject]@{ BuildTypeId = $BuildTypeId }
    }
}
@(
    [pscustomobject]@{ id = 'Backend_Build'; name = 'Backend' }
    [pscustomobject]@{ id = 'Frontend_Build'; name = 'Frontend' }
) | Get-TeamCityConfigurationKey

