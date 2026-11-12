# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class DatedObservation {
    [string]$Id
    [Nullable[DateTimeOffset]]$FinishedAt

    DatedObservation([string]$id, [Nullable[DateTimeOffset]]$finishedAt) {
        $this.Id = $id
        $this.FinishedAt = $finishedAt
    }

    [string] FormatUtc() {
        if ($null -eq $this.FinishedAt) { return 'Unknown' }
        return $this.FinishedAt.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
    }
}
$known = [DatedObservation]::new('1001', [DateTimeOffset]::Parse('2026-11-12T09:00:00-05:00'))
$unknown = [DatedObservation]::new('1002', $null)
$known.FormatUtc()
$unknown.FormatUtc()

