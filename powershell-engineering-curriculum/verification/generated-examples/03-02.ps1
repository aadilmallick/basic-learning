# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function ConvertTo-PositiveScanLimit {
    [CmdletBinding()]
    param([int]$Value)
    if ($Value -lt 1) {
        $exception = [ArgumentOutOfRangeException]::new(
            'Value', $Value, 'Scan limit must be at least one.'
        )
        $record = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'InvalidTeamCityScanLimit',
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $Value
        )
        $PSCmdlet.ThrowTerminatingError($record)
    }
    $Value
}
try { ConvertTo-PositiveScanLimit -Value 0 }
catch { $_.FullyQualifiedErrorId }

