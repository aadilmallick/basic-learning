# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$results = @(
    [pscustomobject]@{
        PipelineId = 'Backend_Build'
        Health = 'RED'
        BoundaryObserved = $false
        OldestObservedRedAt = [DateTimeOffset]::Parse('2026-11-10T14:00:00Z')
    }
)
$csvRows = foreach ($result in $results) {
    [pscustomobject]@{
        PipelineId = $result.PipelineId
        Health = $result.Health
        BoundaryObserved = $result.BoundaryObserved
        OldestObservedRedUtc = $result.OldestObservedRedAt.ToUniversalTime().ToString('O')
    }
}
$csvRows | ConvertTo-Csv -NoTypeInformation

