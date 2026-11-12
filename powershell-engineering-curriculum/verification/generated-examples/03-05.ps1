# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$rows = [Collections.Generic.List[object]]::new()
$failures = [Collections.Generic.List[object]]::new()
foreach ($id in @('Backend_Build', 'Unavailable_Build', 'Frontend_Build')) {
    try {
        if ($id -eq 'Unavailable_Build') { throw 'Simulated permission failure' }
        $rows.Add([pscustomobject]@{ Id = $id; Health = 'GREEN' })
    }
    catch {
        $failures.Add([pscustomobject]@{
            Id = $id
            Message = $_.Exception.Message
        })
    }
}
[pscustomobject]@{
    Eligible = 3
    Inspected = $rows.Count
    Failed = $failures.Count
    IsComplete = ($failures.Count -eq 0)
    Rows = $rows.ToArray()
    Failures = $failures.ToArray()
}

