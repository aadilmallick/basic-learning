# Stage 3 — Errors, reliability, diagnostics, and resource ownership

Reliable automation is not code that never fails. It is code that distinguishes expected absence from failure, stops when continuing would mislead, preserves useful evidence, and releases resources. A report that says “zero red pipelines” after every lookup failed is less reliable than a command that stops with a clear explanation.

The examples use PowerShell 7.4+. **Offline example** blocks deliberately simulate failures; they do not contact TeamCity. Error demonstrations catch their expected failures so the examples complete normally. Stage 2's command contracts now become failure contracts: what happens when an operation cannot fulfill its promise?

## 3.1 Four outcomes that should not collapse into one

For a build-history lookup, distinguish at least these outcomes: valid history containing builds, valid history containing no builds, a malformed response, and a failed request. Returning an empty collection for all four makes downstream analysis impossible. A green report needs evidence of successful inspection, not merely the absence of red rows.

At an application boundary, a result envelope can contain successfully analyzed rows and separately recorded failures. Inside a small helper, throwing on invalid input is often clearer. The choice depends on who can make a useful decision about recovery. A URI constructor cannot decide whether a partial report is acceptable; the orchestration layer can.

There are also two distinct health dimensions. A pipeline's latest known build may be red, green, or other. The scan itself may be complete, partial, or failed. Keep these dimensions separate. An HTTP timeout does not prove a pipeline has an “other” build status.

## 3.2 Terminating and nonterminating errors

PowerShell supports errors that allow a command to continue and errors that terminate the current operation. `try/catch` handles terminating errors. Many cmdlets report nonterminating errors by default, so placing them inside `try` alone is not sufficient.

**Offline example 1 — make a cmdlet failure catchable.**

```powershell
$missing = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.missing')
try {
    Get-Item -LiteralPath $missing -ErrorAction Stop
}
catch {
    [pscustomobject]@{
        ExceptionType = $_.Exception.GetType().FullName
        Category = $_.CategoryInfo.Category
        ErrorId = $_.FullyQualifiedErrorId
    }
}
```

`-ErrorAction Stop` promotes this cmdlet's error into a terminating one. Inside `catch`, `$_` is an `ErrorRecord`, which wraps an exception plus PowerShell-specific context. It includes a category, an identifier, invocation information, and sometimes a target object.

`$ErrorActionPreference = 'Stop'` applies a broader policy in the relevant scope. An entry script can reasonably choose it; a library should still be deliberate at operations where its correctness requires failure. Caller preferences, module scope, and nested calls can otherwise make behavior surprising. Microsoft's [try/catch/finally reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally) defines the control flow.

Do not use `SilentlyContinue` as a general reliability strategy. It changes presentation and continuation behavior, not the underlying result. If an error is expected and harmless, handle that specific case and return a meaningful result.

## 3.3 Throwing, writing an error, and preserving evidence

Use `throw` when the current operation cannot fulfill its contract. Use a nonterminating error when a command deliberately processes independent items and can report an item failure while continuing. For an advanced function, `$PSCmdlet.ThrowTerminatingError()` lets you supply a structured `ErrorRecord` with a stable identifier.

**Offline example 2 — publish a meaningful failure contract.**

```powershell
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
```

The identifier gives callers a more stable discriminator than matching English error text. The exception carries technical details, while the category helps tools organize errors. Do not attach a request object containing credentials as the error target; diagnostic richness should not leak secrets.

Inside a catch block, plain `throw` rethrows the current error. `throw "Request failed: $($_.Exception.Message)"` creates a new error around a string and loses useful structure. If you must add abstraction-level context, preserve the original exception as an inner exception and deliberately define the new error contract.

Catch narrowly when you can recover narrowly. An authentication failure generally needs credential correction, not another identical request. An unavailable optional project label might allow a fallback ID. A malformed build status should not quietly become success. The catch location should reflect who understands the consequence.

## 3.4 Resource lifetime is a design responsibility

A file stream, HTTP response, or disposable reader can hold external resources. Garbage collection manages memory; it does not give you a prompt, deterministic release point for every resource. The code that creates an owned resource should normally dispose it.

**Offline example 3 — release a stream even when work fails.**

```powershell
$stream = [IO.MemoryStream]::new()
try {
    $bytes = [Text.Encoding]::UTF8.GetBytes('TeamCity report')
    $stream.Write($bytes, 0, $bytes.Length)
    "Bytes written: $($stream.Length)"
}
finally {
    $stream.Dispose()
}
"Can write after disposal: $($stream.CanWrite)"
```

The stream is closed whether the body succeeds or throws. Avoid `return` or a new exception in cleanup unless necessary, because cleanup failures can obscure the original problem. For multiple owned resources, nested `try/finally` blocks or carefully ordered cleanup make dependencies clear.

For pipeline functions that allocate once in `begin`, PowerShell 7.3+'s `clean` block handles cleanup when downstream consumers stop early. An `end` block is intended for successful finalization and may not run in all interruption paths. Use `clean` for cleanup across the invocation, and `try/finally` for a resource whose lifetime fits one operation.

Ownership also matters for injected dependencies. If a caller supplies a shared `HttpClient`, a helper should not dispose it after one request unless ownership transfer is explicit. “Always dispose everything” is as incorrect as “let the runtime handle everything.” Dispose what your component owns, at the lifetime boundary it owns.

## 3.5 Retry only when repetition has a reasonable chance of helping

A retry policy needs classification, a limit, a delay, and a deadline. Transient network errors, rate limits, and selected server failures may improve after waiting. Bad credentials, missing permissions, invalid locators, and invalid JSON usually will not. Repeating every failure wastes time and can hide the real cause.

An idempotent operation has the same intended effect when repeated. GET requests are generally good retry candidates. Retrying a POST that queues a TeamCity build may create duplicate work if the first request succeeded but its response was lost. That operation needs a separate idempotency or reconciliation strategy.

**Offline example 4 — a bounded retry mechanism with injected policy.**

```powershell
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
```

The example finishes with `completed` and three attempts, without sleeping. A mutable state object makes the simulation independent of child-scope variable rebinding. The delay is injected so a test can observe timing decisions without spending real time.

This is a mechanism demonstration, not a complete HTTP retry policy. A production adapter should examine HTTP status, respect valid `Retry-After` values, add bounded jitter when many clients may retry together, and impose an overall time budget. Do not stack your own retries on top of cmdlet retries without calculating the resulting maximum attempts and duration.

Discard partial success output from an attempt before retrying it. The example captures the operation's output inside parentheses before returning it; an operation that streams externally visible side effects remains unsuitable for transparent repetition. Report-level orchestration should know which stage may be repeated safely.

## 3.6 Timeouts, cancellation, and latency budgets

A timeout bounds a request phase or operation; it does not necessarily bound the entire scan. One hundred configurations multiplied by three attempts and a long request timeout can turn a report into an hours-long job. Model the total budget as discovery plus per-configuration work plus rendering and writing.

PowerShell web-cmdlet timeout parameters vary across releases. Inspect `Get-Command Invoke-RestMethod -Syntax` on the target agent and use the version-specific [Invoke-RestMethod documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod). This curriculum's reference adapter uses the broadly available `TimeoutSec` parameter for its PowerShell 7 baseline and documents its limited policy.

Cancellation is separate from failure recovery. If a user stops a scan, cleanup should run, but the command should not catch the cancellation and pretend the scan completed. Avoid broad catch blocks around the entire application that always produce a success-looking file.

## 3.7 Partial scans need explicit accounting

**Offline example 5 — preserve successful data and failed inspections.**

```powershell
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
```

The invariant is `Eligible = Inspected + Failed` for this simple workflow. A fuller scan also tracks excluded and invalid configurations. The report can say “2 inspected, 1 unavailable” instead of presenting two green rows as a complete server assessment.

The percentage denominator must be explicit. “Red among inspected pipelines” differs from “red among all eligible pipelines,” where some outcomes are unknown. Do not manufacture unknown pipeline health merely to make a pie chart add to 100 percent. Present scan coverage alongside health results.

Warning messages help a person watching a terminal, but they are insufficient evidence in a saved HTML artifact. Persist safe failure metadata with the report. A scheduled job's downstream readers may never see its console output.

## 3.8 Logs, errors, and data serve different audiences

Data output supports composition. Errors communicate failed operations. Logs support diagnosis over time. Keep these purposes separate even if a CI system later combines their visual display. Useful log context includes a scan ID, operation name, configuration ID, attempt number, elapsed time, and safe HTTP status.

Do not log tokens, headers, credential objects, or arbitrary response bodies by default. Error messages themselves can include sensitive URLs or parameters; sanitization belongs near the external boundary. A `hidden` property only changes ordinary display and discovery, not the underlying information's accessibility.

Structured log objects are often easier to process than custom strings. At an application boundary, write them as JSON lines with an explicitly selected schema. Avoid mixing those lines into a function's data output. A logger dependency can write to the information stream, a file, or a test collector.

## 3.9 Process exit codes belong to the executable boundary

Reusable functions should normally throw or emit error records rather than call `exit`, which can end the hosting process. An entry script can map outcomes to an exit code. For example, code 0 may mean a complete scan, code 1 an unrecoverable application failure, and code 2 a partial scan if your CI policy treats that separately.

For native programs, inspect `$LASTEXITCODE` immediately after the invocation; `$?` is not an interchangeable record of a native program's numeric result. Native stderr and nonzero exit handling have version-sensitive options, so document your baseline. A validation script should explicitly fail its process when a check fails rather than relying on how a particular host displays an error.

## 3.10 Protect a file boundary and preserve the original failure

A retryable read and a publish operation have different reliability properties. A file writer should finish constructing content before exposing it as the final artifact. A temporary sibling file can reduce the chance of readers observing a partially written destination. It does not automatically make a three-file report transactionally consistent, and network filesystems can have additional semantics.

**Offline example 6 — verify cleanup on an intentionally failed operation.**

```powershell
$path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.temporary')
$stream = $null
try {
    $stream = [IO.File]::Open($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
    $stream.WriteByte(65)
    throw [InvalidOperationException]::new('Simulated render failure')
}
catch {
    "Handled: $($_.Exception.Message)"
}
finally {
    if ($null -ne $stream) { $stream.Dispose() }
    if ([IO.File]::Exists($path)) { [IO.File]::Delete($path) }
}
"Temporary file exists: $([IO.File]::Exists($path))"
```

The stream is disposed before deletion, so Windows does not retain an open handle that prevents cleanup. The final value is false. This example owns the exact generated path and deletes only that file; it does not use a broad wildcard to clean a directory shared with other work.

At the application level, a request deadline and cleanup deadline may differ. If the scan is canceled, you should still have a bounded opportunity to close resources and remove temporary files. Avoid starting fresh network work from cleanup. Cleanup should restore a safe local state, not attempt to complete the business workflow after cancellation.

Another practical rule is to preserve the primary failure when cleanup also fails. Record a cleanup problem as additional diagnostic context where possible. Replacing an authentication error with a temporary-file deletion error makes the user fix the wrong thing first. Reliability includes the quality of the explanation, not just the fact that a process stopped.

## 3.11 The TeamCity report's reliability decisions

The uploaded script sets strict mode and stop-on-error, catches failures for individual pipelines, warns, and continues. This makes one unavailable configuration less likely to prevent every report. The consequence is that the final totals describe successfully inspected rows, while failed inspections disappear from those totals. Stage 11 demonstrates that behavior with extracted functions, and stage 12 adds explicit scan accounting in its teaching implementation.

The script also catches date parsing failures and returns null. That is a reasonable representation of an unknown date, provided the report says “Unknown” rather than assigning a false timestamp. Its final output catch throws a new string, which simplifies the message but discards structure. A modular writer can preserve the original error and add the destination path through a deliberate error record.

Reliability comes from these small, explicit decisions. Every fallback should answer two questions in prose: what evidence is being lost, and how will the caller or report reader know? When those answers are clear, the code becomes easier to test and much harder to misinterpret.

## 3.12 Work through a failed scan without losing the truth

Imagine discovery succeeds and returns twenty eligible configurations. The first seven histories are read successfully. The eighth request times out, the ninth is forbidden, and the remaining eleven succeed. The application now has eighteen inspected outcomes and two unavailable outcomes. It has not inspected twenty pipelines successfully, even though it attempted twenty requests.

The timeout may be retryable under a bounded policy. If retry succeeds, the final inspected count can become nineteen. The forbidden response should normally remain a failure until credentials or permissions change. Repeating it with the same token consumes time without adding evidence. Classification therefore affects both operational efficiency and the truthfulness of the final report.

Suppose the application catches both failures and emits warnings. That is useful while watching the terminal, but the HTML still needs coverage metadata. A colleague opening it later should see that one configuration remained unavailable. If all nineteen inspected pipelines are green, the correct conclusion is “no red pipelines among inspected results,” accompanied by the coverage gap.

Now suppose rendering succeeds but the destination directory is unavailable. This is a publication failure, not a failed health analysis. Keeping the scan snapshot separate from writing lets you diagnose the stage accurately and possibly save the snapshot elsewhere. A monolithic catch that says only “report failed” loses this distinction.

If the first artifact was replaced before the second write failed, publication is partial too. Do not claim one transaction merely because each file uses a temporary sibling. A stronger publishing model writes a complete versioned directory, validates it, and then updates a single index or pointer. That design has its own filesystem and reader assumptions, so adopt it only when consistent multi-file viewing matters.

The same reasoning applies to fallback project labels. Health evidence can be complete while hierarchy grouping is approximate. Keep a separate fallback count instead of treating the whole scan as either perfectly complete or entirely failed. Reliability often improves by adding a second dimension rather than inventing a more complicated single status string.

## 3.13 Build an operational budget from the outside inward

A request timeout is only one part of a scan's duration. Include configuration discovery, project lookups, history pages, retry delays, rendering, and writes. A cache can reduce project requests, while a history limit reduces observations; neither guarantees a fixed wall-clock duration when a server is slow.

Start with a job-level budget that makes sense for the report's purpose. A report needed before a daily meeting may tolerate several minutes but not an hour. Allocate some of that budget to retrieval and leave time for rendering, writing, and cleanup. When the remaining budget is too small for another useful attempt, stop retrying and record the unavailable inspection.

Exponential delay is a way to reduce repeated pressure, not a substitute for a deadline. With several retry layers, the total attempts can multiply. If an HTTP cmdlet retries internally and the application retries the whole history lookup, one apparent “three-attempt” policy may produce far more requests. Put retry ownership at one clear layer and record attempts there.

Jitter helps when many agents run the same report at the same time. Without it, they may fail together, wait the same interval, and retry together. A bounded random addition spreads load, but tests should inject the delay calculation or random source so outcomes remain reproducible. Do not make unit tests sleep through real backoff intervals.

Cancellation should end useful work promptly. A cancellation signal is not permission to continue scanning silently and publish a normal-looking result. Cleanup may still close streams and remove temporary files, but new requests should stop. If you choose to persist a canceled partial snapshot, label it as canceled and incomplete.

Finally, decide who receives which explanation. A report reader needs safe coverage and outcome information. An operator needs operation identifiers, safe status codes, and timing. A developer may need stack and inner-exception details. One giant raw exception dump serves none of these audiences particularly well and can expose credentials or internal request details. Structured boundaries let you retain diagnostic value while publishing only the information each audience needs.

An explicit recovery table helps keep this policy consistent. An invalid URI fails before discovery. A discovery failure prevents a complete configuration inventory and normally stops the run. A single history failure can become one unavailable inspection. A hierarchy failure can preserve health while marking grouping approximate. A render failure prevents publication of that view. A write failure leaves the scan calculation valid but publication unsuccessful.

The table does not need to be implemented as a framework. It is a concise statement of responsibility that guides catch placement and tests. Each catch should either recover according to that policy or propagate the error. If a catch merely suppresses an exception because continuing seems convenient, it probably needs a clearer result contract.
