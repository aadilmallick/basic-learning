# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function ConvertTo-BuildObservation {
    [CmdletBinding()]
    param([Parameter(Mandatory)][psobject]$Dto)
    $idProperty = $Dto.PSObject.Properties['id']
    $statusProperty = $Dto.PSObject.Properties['status']
    if ($null -eq $idProperty -or [string]::IsNullOrWhiteSpace([string]$idProperty.Value)) {
        throw 'Build response is missing a usable id.'
    }
    if ($null -eq $statusProperty -or [string]::IsNullOrWhiteSpace([string]$statusProperty.Value)) {
        throw 'Build response is missing a usable status.'
    }
    [pscustomobject]@{
        Id = [string]$idProperty.Value
        Status = ([string]$statusProperty.Value).ToUpperInvariant()
    }
}
ConvertTo-BuildObservation -Dto ([pscustomobject]@{ id = 1001; status = 'failure' })

