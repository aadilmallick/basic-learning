# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Invoke-BoundedOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Operation,
        [Parameter(Mandatory)][scriptblock]$ShouldRetry,
        [ValidateRange(1, 10)][int]$MaxAttempts = 3,
        [scriptblock]$Delay = { param($milliseconds) Start-Sleep -Milliseconds $milliseconds }
    )
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try { return (& $Operation) }
        catch {
            $failure = $_
            if ($attempt -eq $MaxAttempts -or -not (& $ShouldRetry $failure)) {
                throw
            }
            $milliseconds = [int][Math]::Min(1000 * [Math]::Pow(2, $attempt - 1), 8000)
            & $Delay $milliseconds | Out-Null
        }
    }
}
$state = @{ Attempts = 0 }
$operation = {
    $state.Attempts++
    if ($state.Attempts -lt 3) { throw [TimeoutException]::new('Simulated timeout') }
    'completed'
}.GetNewClosure()
Invoke-BoundedOperation -Operation $operation -ShouldRetry {
    param($failure)
    $failure.Exception -is [TimeoutException]
} -Delay { param($milliseconds) }
"Attempts: $($state.Attempts)"

