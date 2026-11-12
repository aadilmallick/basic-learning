# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$rows = [System.Collections.Generic.List[object]]::new()
$byId = [System.Collections.Generic.Dictionary[string, object]]::new(
    [StringComparer]::Ordinal
)
foreach ($id in @('Backend', 'backend')) {
    $row = [pscustomobject]@{ Id = $id; Status = 'SUCCESS' }
    $rows.Add($row)
    $byId.Add($id, $row)
}
$rows.Count
$byId.Count
@($rows | Where-Object Id -eq 'Backend').Count
@($rows | Where-Object Id -ceq 'Backend').Count

