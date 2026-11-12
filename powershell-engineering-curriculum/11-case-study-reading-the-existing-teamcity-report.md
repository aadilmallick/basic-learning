# Stage 11 — Read and characterize the uploaded TeamCity report

This chapter analyzes the actual uploaded [New-RedTeamCityPipelineHtmlReport.txt](reference/New-RedTeamCityPipelineHtmlReport.txt), preserved byte-for-byte in this package. It contains 913 lines as read by `Get-Content`. Its SHA-256 is `4B2B3C42471D3AAFA5D6D4B96E4D6CA1436334929EA44E85FADBA32E10FF7AB2`. Line references below refer to this preserved file, not an imagined replacement. The earlier short curriculum described it as 914 lines; this edition uses the measured file.

The goal is to understand behavior before improving architecture. Source observations, offline characterization, and proposals are distinguished throughout. No live TeamCity server was needed to inspect the code. Stage 12's teaching implementation is a modular companion, not a claim of production drop-in equivalence.

## 11.1 Read the script as a data-flow program

The program has four phases: configure the connection and policies, discover configurations, inspect each eligible configuration, and render/write three artifacts. Most functions are defined before the main execution begins at line 854. Reading only from top to bottom can obscure this structure; first locate the entry point, then follow its dependencies.

The entry loop calls `Get-TeamCityBuildTypes`, filters names, invokes `Get-PipelineInfo`, and accumulates all successful rows plus a red-only subset. The analyzer calls hierarchy lookup and build-history retrieval. The three renderers consume rows but also read outer configuration variables. This is the dependency graph the refactor needs to disentangle.

The script uses several good techniques already: advanced script binding, bounded history, query-component encoding, HTML encoding, cached project lookup, explicit array collection, and warning-and-continue behavior for individual inspections. A careful refactor preserves useful decisions while making their consequences visible.

## 11.2 Configuration and startup: lines 44–84

The script parameters include server URL, token, project and pipeline exclusions, page size, history limit, and three output destinations. The token defaults to an environment variable and falls back to an ordinary `Read-Host` prompt. That prompt is not secure input; it produces a normal string and is unsuitable for an unattended job.

Strict mode and `$ErrorActionPreference = 'Stop'` establish a strong script-level failure policy. The API root is normalized by trimming a slash and appending `/app/rest` unless a regular-expression match finds that segment. The headers request JSON and carry bearer authorization. A hashtable caches project responses by ID.

These are application and connection concerns. A reusable client should receive a validated URI and credential. The entry script should decide whether to prompt or require injected credentials. A renderer should not know how authentication was obtained. The company-specific defaults remain in the preserved reference, while general teaching examples use `ci.example.com`.

The regular-expression root check is convenient but less precise than structured path validation. It does not establish HTTPS or reject query/fragment/user-info components. That is a proposed robustness improvement, not evidence that the configured production URL was invalid.

## 11.3 URI and HTTP helpers: lines 86–118

`New-TeamCityUri` joins a resource path to `$apiRoot` and percent-encodes every query key and value with `EscapeDataString`. That is the correct layer for query transport encoding. The helper returns a string URI. `Invoke-TeamCityGet` calls it and invokes `Invoke-RestMethod` with outer `$headers`.

The helpers are already a useful seam because request construction and execution are centralized. Their hidden dependencies are `$apiRoot` and `$headers`. Moving the definitions into a module without replacing those dependencies would change their scope environment and may break them.

A client instance can own the root and token; a transport function can perform the request. Tests can replace the transport and inspect constructed URIs. Query encoding should remain, while locator-value validation must be added separately because percent encoding does not sanitize TeamCity's decoded locator language.

No explicit request timeout, redirect policy, or retry classification appears in these helpers. Those are operational gaps to address deliberately. Do not add indiscriminate retries and claim improved reliability; stage 3 explains why authentication and malformed-query failures need different handling.

## 11.4 Defensive access and filtering: lines 120–160

`Get-PropertyValue` accepts null, looks up `$InputObject.PSObject.Properties[$Name]`, and returns null when the property is absent. This avoids strict-mode exceptions for optional JSON fields. It also collapses missing and explicitly null values, which can hide a malformed required response if used indiscriminately.

`Test-NameExcluded` ignores blank patterns and uses `-like`. Matching is wildcard-based and case-insensitive under ordinary PowerShell semantics. A pattern such as `Sandbox*` is not a regular expression. Escaping and matching policy should remain compatible when this helper moves.

The main loop applies project exclusions to each configuration's immediate `projectName` before hierarchy traversal. It does not automatically exclude descendants when only an ancestor's name matches. A future “exclude project subtree” feature requires a different policy and should not be smuggled into a structural extraction.

Name-based exclusions are convenient for people but can become ambiguous when labels repeat. IDs are stronger machine selectors. A future interface can support both, with clear parameter names and help explaining scope.

## 11.5 Dates and HTML text: lines 162–216

`ConvertFrom-TeamCityDate` returns null for blank input, normalizes numeric offsets such as `-0500` to `-05:00`, tries six exact formats with invariant culture, then attempts a broader parse. On success it returns `.LocalDateTime`. On every parse failure it returns null.

This is resilient for optional display dates, and the renderers use `Unknown` when parsing fails. The tradeoff is that the stored `DateTime` has already been converted to the executing machine's timezone. A report generated on another agent can display a different clock time for the same instant. Keeping `DateTimeOffset` until presentation makes the timezone choice explicit.

The broad fallback can depend on parsing conventions beyond the documented compact format. A new client should define accepted formats and unknown behavior. A compatible extraction can preserve the old parser first, then change the model and presentation together with targeted tests.

`ConvertTo-HtmlText` calls `WebUtility.HtmlEncode`. That protects ordinary text and quoted attribute values from markup injection. It does not reject a `javascript:` URL. Text encoding and allowed link destinations are different checks, as the offline renderer tests demonstrate.

## 11.6 Project identity, caching, and traversal: lines 218–315

`Test-TeamCityRootProject` recognizes `_Root` and two root display names. The stable ID is the stronger signal; name recognition is a compatibility fallback. `Get-TeamCityProjectInfo` returns cached responses or requests `id,name,parentProject(id,name)` and stores the successful result.

`Get-TopLevelProjectName` fetches the current project and walks parents until the root. On lookup failure it writes a warning and returns the immediate project's fallback name. This preserves a usable chart label but does not tell the saved report which groups used degraded information.

The traversal assumes a valid terminating hierarchy and has no seen-ID set or depth bound. A cycle in a malformed fixture or response can loop indefinitely even if normal TeamCity data is a tree. Add explicit termination protection in the client boundary. Cache final ancestor resolutions if repeated walks become a measurable cost.

The result is only a name. Distinct top-level project IDs sharing a name can merge in chart grouping. Carry ID and name together so grouping uses identity while display uses labels. If a fallback is used, retain metadata about that fallback rather than silently treating it as verified ancestry.

## 11.7 Configuration pagination: lines 317–343

`Get-TeamCityBuildTypes` starts at zero and requests non-template configurations with `count:$PageSize,start:$start`. It asks for `count,nextHref` and selected configuration fields, emits each item, and stops when the page is short or `nextHref` is blank. Otherwise it increments the offset by page size.

The code uses `nextHref` only as a signal, not as the next request destination. A short page with a valid continuation stops early. Whether that occurs in the actual deployment requires server evidence, but the source behavior is clear and easy to test with a fixture.

A stronger client follows the returned continuation after validating its origin and REST path. It detects repeated continuations, limits page count, and deduplicates IDs. These are bounded protocol behaviors, not merely performance improvements. JetBrains' [pagination documentation](https://www.jetbrains.com/help/teamcity/rest/locators.html) supports treating continuation metadata as part of the collection contract.

Discovery failure occurs before the per-pipeline try/catch in the main loop. Therefore a failed initial discovery is a whole-run failure, while an individual history failure is warning-and-continue. That difference is sensible but should be documented in the command's error contract.

## 11.8 History retrieval: lines 345–362

`Get-RecentFinishedBuilds` requests a bounded collection using `state:finished`, `personal:false`, `canceled:false`, `defaultFilter:false`, and the configured count. It requests build ID, number, status, finish date, and web URL. It does not request or follow build-history continuation metadata.

The script trusts the returned order and uses the first build as latest. It does not explicitly choose a branch. Disabling the default filter affects the build universe, so do not describe this code as default-branch-only without verifying the actual server response. See [BuildLocator](https://www.jetbrains.com/help/teamcity/rest/buildlocator.html) for the server's filtering dimensions.

The requested count is an upper bound on observations, not evidence that exactly that many were scanned. Retention, filters, permissions, and server lookup behavior can all reduce returned history. The HTML metric's “builds scanned per pipeline” wording overstates the guarantee; “maximum builds requested per pipeline” is more precise.

## 11.9 Pipeline analysis: lines 364–464

`Get-PipelineInfo` first reads project and pipeline fields, resolves a top-level label, and rejects a blank configuration ID by returning null. It then retrieves history. With no builds, it creates an `OTHER` row with raw status `NO_BUILDS`, zero red count, false red/green flags, and no dates.

With history, it normalizes the latest status to uppercase. `FAILURE` or `ERROR` maps to `RED`; `SUCCESS` maps to `GREEN`; everything else maps to `OTHER`. This is the source's local compatibility policy. It is not a claim that `ERROR` is emitted as a normal status by every TeamCity version.

For a red latest build, the loop counts only the leading contiguous red observations. It updates `$redSinceBuild` while walking backward through them and stops at the first non-red build. An older failure after that boundary is irrelevant to the current streak.

`CurrentRedBuildDate` is the latest red build's finish date. `BecameRedDate` is the oldest observed red build's finish date. These fields answer different questions and must not be merged during cleanup. `RedBuildCount` counts the observed prefix, not all failed builds in the window.

| Newest-first statuses | Health | Red count | Boundary found | Wording |
|---|---|---:|---|---|
| SUCCESS, FAILURE | GREEN | 0 | Not used | No red-start label |
| FAILURE, ERROR, SUCCESS | RED | 2 | Yes | Oldest prefix date |
| FAILURE, FAILURE | RED | 2 | No | At least since oldest observed red |
| FAILURE, UNKNOWN, FAILURE | RED | 1 | Yes | Latest red date |
| No builds | OTHER | 0 | Not used | No finished builds |

The `UNKNOWN` row exposes a documentation mismatch: the description mentions finding green, but the implementation stops at any non-red status. A compatibility extraction preserves implementation first. A later policy can treat unknown as an uncertain gap, but that is an intentional change.

When no boundary is found, “At least since” expresses a lower bound on streak duration. The actual start is at or before the oldest observed red timestamp; the timestamp is not a lower bound on the chronological start. This distinction prevents a subtle but important misuse of the phrase “lower bound.”

Even when a success boundary is observed, the date is an operational streak marker based on build finish times, not the actual moment a defect was introduced. Report labels should reflect what the evidence supports.

## 11.10 Execute extracted functions without running startup

The following **Offline example** parses the preserved file and inventories function definitions. It does not execute any part of that file. Run it from the curriculum root; the verification runner supplies that working directory.

```powershell
$path = Join-Path (Get-Location) 'reference/New-RedTeamCityPipelineHtmlReport.txt'
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $path, [ref]$tokens, [ref]$parseErrors
)
if ($parseErrors.Count) { throw 'Source contains parse errors.' }
$functions = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [System.Management.Automation.Language.FunctionDefinitionAst]
})
$functions | Select-Object Name, @{ Name = 'StartLine'; Expression = { $_.Extent.StartLineNumber } }
```

The bundled [characterization runner](verification/Test-OriginalBehavior.ps1) takes the next controlled step: it evaluates only these known function definitions inside an isolated temporary module, replaces history and hierarchy lookups with fixtures, and invokes the original analyzer. It never evaluates the source's top-level parameter block or main statements.

Parsing arbitrary source is not the same as safely executing it. Function bodies are still executable code. The extraction is appropriate here because the source is the user's designated case study and the runner deliberately controls which functions are called. It is not a general security mechanism for untrusted programs.

## 11.11 HTML generation: lines 466–851

`New-ReportHtml` consumes red rows, sorts by immediate project, streak date, and pipeline name, then renders project tables. It encodes names, labels, and URLs before insertion. It also reads outer `$TeamCityUrl` and `$MaxBuildsToScan`, which are hidden rendering dependencies.

`New-SummaryReportHtml` counts green, red, and other across successful rows. It calculates overall percentages and pie-chart angles, then immediate-project summaries. CSS angles use invariant-culture numeric strings, which avoids locale-specific decimal commas breaking CSS.

`New-ProjectChartsReportHtml` groups by top-level project name, falling back to immediate project name, then creates one chart card per group. The chart data is computed inside rendering, so several layers repeat counting and formatting knowledge. A shared summary function and document shell would reduce that duplication.

The empty overall chart uses zero angles and a remaining gray segment; textual counts remain zero. A new renderer can show an explicit empty state instead of a full gray circle that might imply an “other” pipeline. This is a presentation improvement to describe, not silently treat as byte-for-byte compatibility.

HTML encoding is a strength, but encoded URL text can still carry an unsafe scheme. Validate allowed absolute schemes before creating an anchor, and render the label without a link when invalid. Keep chart values derived from validated counts rather than accepting arbitrary CSS from external data.

## 11.12 Main loop and writes: lines 854–913

The loop updates progress, applies immediate-name exclusions, and catches each inspection failure. Successful rows are appended with `+=`; red rows are also appended to a second array. Lists or one collection followed by filtering express accumulation more directly, though performance should be measured on the target runtime.

Failed inspections and null results are omitted from final totals. A report can therefore show no red pipelines even when some configurations were unavailable. The improvement is explicit accounting: listed, excluded, eligible, inspected, failed, and grouping-fallback counts. Keep pipeline health separate from scan coverage.

The three reports receive separate `Get-Date` calls and are written sequentially using `Set-Content`. They can have slightly different timestamps. If the second write fails, the first file may already be new while the others remain old. Render first, use one scan timestamp, and define whether multi-file consistency matters.

The final catch throws a new message string, losing some original error structure. The concluding `Write-Host` messages are useful for people but do not provide a structured artifact result to automation. A modular entry script can return paths and scan metadata while preserving a clear process-level failure policy.

## 11.13 A justified migration order

First preserve source and characterize no-build, known-boundary, all-red, and unknown-boundary cases. Then extract the pure analyzer with explicit observation input. Next isolate API configuration and transport, then hierarchy lookup and caching. Move renderers behind explicit rows and metadata. Finally replace orchestration and output handling.

Maintain the three report purposes and wildcard semantics during extraction. Treat branch policy, timezone display, grouping by ID, safe links, and coverage metadata as named changes. The next chapter provides a runnable teaching implementation and explains exactly where it preserves policy and where it deliberately improves the contract.

## 11.14 Trace the source algorithm with concrete timestamps

Take a fictional history returned newest first: failure on November 12, error on November 11, success on November 10, and failure on November 9. `Get-PipelineInfo` chooses the November 12 observation as latest, classifies the configuration red, and assigns that finish time to the current-red-build date.

The loop begins with the latest observation. It increments the red count and stores that build as the oldest red candidate so far. The November 11 error is also red under the source's policy, so the count becomes two and the candidate moves backward. The November 10 success is non-red, so the loop sets its boundary flag and stops. The November 9 failure is never part of this streak.

The resulting became-red marker is November 11, not November 12 and not November 9. It represents the oldest red observation after the encountered non-red boundary. A report reader can distinguish this from the latest red build date. Keeping both fields is useful when a pipeline has remained red across several builds.

Now remove the success and the older failure so only the two red observations remain. The same candidate is November 11, but no boundary was seen. The timestamp alone is unchanged; its confidence differs. The source adds “At least since” because the streak may extend further backward. This is why a refactored result needs an evidence flag rather than only a timestamp.

Finally replace the success with `UNKNOWN`. The original loop still stops there and treats the boundary as found. The case demonstrates the difference between “not red under this policy” and “known healthy.” A new uncertainty policy could distinguish them, but source compatibility must acknowledge what the current loop actually does.

## 11.15 Separate proven behavior from potential defects

Some findings are direct source facts: history is requested once, `nextHref` content is not followed for configuration paging, branch selection is not explicit, and per-pipeline failures are omitted from row totals. These statements do not depend on guessing the live server's data.

Other findings describe possible consequences: a short page with a continuation could be skipped, duplicate project names could merge, and a cycle could prevent hierarchy traversal from terminating. The source permits these outcomes under suitable input, but that does not establish that they have occurred in production. Fixtures demonstrate the mechanism without making unsupported operational claims.

A third category is design tradeoff. Converting to local time may be exactly what the original author wanted. Warning-and-continue may be appropriate for a report that values partial information. The improvement is to make timezone and completeness visible, not to declare every resilient fallback a bug.

Prioritize changes by consequence. Misrepresenting unavailable data as a complete healthy scan affects interpretation. Losing continuation pages affects coverage. Token and link handling affect boundaries. Duplicate CSS is a maintenance cost. These are all worth understanding, but they do not deserve the same urgency or the same test strategy.

## 11.16 Preserve a baseline that another engineer can review

Keep the original source unchanged and record its checksum. Save representative input fixtures and the corresponding interpreted results. For rendered output, compare meaningful content and labels before requiring identical bytes; timestamps, whitespace, and CSS ordering can change without changing the report's meaning.

At the same time, do not dismiss every visual difference as harmless. A missing lower-bound prefix, an omitted failure notice, or a changed grouping denominator alters the reader's conclusion. Baseline review should focus on those semantic elements as well as required columns and links.

The original function seams make this practical. Substitute histories and hierarchy labels, invoke the real source analyzer, and capture its row fields. Then feed equivalent normalized observations into the new analyzer. Agreement on classification, prefix count, candidate timestamp, and uncertainty provides focused evidence for extraction.

When the new implementation differs intentionally, retain both expectations with explanatory names. This keeps the original behavior discoverable and the new contract explicit. The result is a migration that another engineer can assess from source, fixtures, and tests rather than trusting a claim that the rewritten script is simply cleaner.
