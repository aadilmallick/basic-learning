# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
class HealthReader {
    hidden [scriptblock]$loadBuilds

    HealthReader([scriptblock]$loadBuilds) {
        if ($null -eq $loadBuilds) { throw 'A build source is required.' }
        $this.loadBuilds = $loadBuilds
    }

    [string] GetLatestStatus([string]$buildTypeId) {
        $builds = @(& $this.loadBuilds $buildTypeId)
        if ($builds.Count -eq 0) { return 'NO_BUILDS' }
        return [string]$builds[0].Status
    }
}
$fixtureSource = {
    param($buildTypeId)
    [pscustomobject]@{ Id = '101'; Status = 'FAILURE'; BuildTypeId = $buildTypeId }
}
$reader = [HealthReader]::new($fixtureSource)
$reader.GetLatestStatus('Backend_Build')

