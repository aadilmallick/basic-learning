# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
enum PipelineHealthKind { Green; Red; Other }
function ConvertTo-HealthKind {
    param([string]$Status)
    switch ($Status.ToUpperInvariant()) {
        'SUCCESS' { [PipelineHealthKind]::Green; break }
        'FAILURE' { [PipelineHealthKind]::Red; break }
        'ERROR' { [PipelineHealthKind]::Red; break }
        default { [PipelineHealthKind]::Other }
    }
}
foreach ($status in @('SUCCESS', 'FAILURE', 'UNKNOWN')) {
    [pscustomobject]@{ RawStatus = $status; Health = ConvertTo-HealthKind $status }
}

