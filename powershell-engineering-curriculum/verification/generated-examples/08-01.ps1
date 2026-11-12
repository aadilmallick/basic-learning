# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Get-HealthInterpretation {
    param([string]$RawStatus)
    [pscustomobject]@{
        RawStatus = $RawStatus
        Health = if ($RawStatus -eq 'SUCCESS') { 'GREEN' }
                 elseif ($RawStatus -in @('FAILURE', 'ERROR')) { 'RED' }
                 else { 'OTHER' }
    }
}
$result = Get-HealthInterpretation -RawStatus 'FAILURE'
$result | ConvertTo-Json -Compress
'Pipeline health: {0} (raw status: {1})' -f $result.Health, $result.RawStatus

