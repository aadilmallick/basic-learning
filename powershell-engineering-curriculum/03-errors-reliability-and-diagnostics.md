# Stage 3: Errors, Reliability, and Diagnostics

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Failure is part of the interface
Network calls fail, credentials expire, output directories are unwritable, and APIs return incomplete data. A professional script must distinguish *expected absence*, *recoverable failure*, and *fatal failure*.

### Terminating versus non-terminating errors
```powershell
try {
    Get-Content -LiteralPath './missing.txt' -ErrorAction Stop
} catch [System.Management.Automation.ItemNotFoundException] {
    Write-Warning 'Optional file is absent'
} catch {
    throw
}
```
Many cmdlets emit non-terminating errors by default; `-ErrorAction Stop` makes them catchable. `throw` creates a terminating error. `$_` in `catch` is an `ErrorRecord`, whose `.Exception` and `.ScriptStackTrace` help diagnose failures.

### Do not erase context
```powershell
try {
    Invoke-RestMethod -Uri 'https://example.invalid/api' -ErrorAction Stop
} catch {
    Write-Error -ErrorRecord $_
    throw
}
```
In a library, usually prefer `throw` alone unless adding meaningful context. Replacing the original exception with a plain string loses useful exception type and stack information.

### Bounded retries: transient failures only
```powershell
function Invoke-WithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Operation,
        [ValidateRange(1,10)][int]$Attempts = 3
    )
    for ($attempt=1; $attempt -le $Attempts; $attempt++) {
        try { return & $Operation }
        catch {
            if ($attempt -eq $Attempts) { throw }
            Start-Sleep -Seconds ([Math]::Min(8,[Math]::Pow(2,$attempt-1)))
        }
    }
}
```
This is a *mechanism demonstration*, not a production HTTP retry policy: a real client should retry only recognized transient conditions (such as 429/502/503/504 or network timeouts), respect `Retry-After`, use jitter, and avoid retrying unsafe non-idempotent writes blindly. Never retry 401 authorization failures without a deliberate refresh policy.

### Cancellation and resources
`try/finally` ensures cleanup even on failure:
```powershell
$writer = [System.IO.StringWriter]::new()
try { [void]$writer.WriteLine('Report') ; $writer.ToString() }
finally { $writer.Dispose() }
```
Prefer `Set-Content -LiteralPath ... -Encoding utf8` for ordinary file writes. For critical reports, write to a temporary file and then move it into place to reduce the chance of leaving a partial artifact.

### Diagnostics without leaking credentials
```powershell
function Get-SafeRequestSummary {
    param([string]$Method,[string]$Path)
    [pscustomobject]@{ Method=$Method; Path=$Path; Timestamp=[DateTimeOffset]::UtcNow }
}
```
Log method, endpoint path, duration, status code, and correlation ID when available. Never log bearer tokens, Authorization headers, or full request objects containing secrets. Treat CI logs and generated HTML as potentially shareable artifacts.

### Partial success is not full success
The source script catches failures per pipeline, warns, and continues. This is useful for resilience but creates a reporting ambiguity: '100 pipelines scanned' may mean 100 *successfully inspected*, not 100 discovered. Model `DiscoveredCount`, `InspectedCount`, and `FailedCount` separately and label partial reports clearly. Consider nonzero exit codes when report completeness is required by CI.

### Operational contract
Document exit behavior: success with complete data, success with warnings/partial data, and fatal failure. Use `Write-Verbose` for diagnostic details, `Write-Warning` for degraded results, and terminating errors for broken invariants. Do not rely solely on `$ErrorActionPreference='Stop'` to control every external command or native process exit code.
