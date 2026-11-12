# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class BuildObservation {
    [string]$Id
    [string]$Number
    [string]$Status

    BuildObservation([string]$id, [string]$number, [string]$status) {
        if ([string]::IsNullOrWhiteSpace($id)) { throw 'Build ID is required.' }
        $this.Id = $id
        $this.Number = $number
        $this.Status = $status.ToUpperInvariant()
    }

    [bool] IsRed() {
        return $this.Status -in @('FAILURE', 'ERROR')
    }

    [string] ToString() {
        return '{0} #{1}: {2}' -f $this.Id, $this.Number, $this.Status
    }
}
$build = [BuildObservation]::new('1001', '2026.11.12.1', 'failure')
$build.IsRed()
$build.ToString()
$build | Get-Member

