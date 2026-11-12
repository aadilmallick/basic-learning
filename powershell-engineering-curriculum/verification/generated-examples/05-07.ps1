# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function New-FixtureStatusReader {
    param([string]$Status)
    $state = @{ Status = $Status; Calls = 0 }
    $read = {
        param($id)
        $state.Calls++
        [pscustomobject]@{ Id = $id; Status = $state.Status; Call = $state.Calls }
    }.GetNewClosure()
    [pscustomobject]@{ Read = $read; State = $state }
}
$redSource = New-FixtureStatusReader -Status FAILURE
$greenSource = New-FixtureStatusReader -Status SUCCESS
& $redSource.Read 'A'
& $redSource.Read 'B'
& $greenSource.Read 'C'

