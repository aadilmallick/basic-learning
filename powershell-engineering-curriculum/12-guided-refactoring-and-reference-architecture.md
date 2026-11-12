# Stage 12 — Guided refactoring with a runnable modular implementation

This chapter turns the source analysis into a concrete application you can inspect and run. The complete [reference implementation](examples/ReferenceImplementation/New-TeamCityHealthReport.ps1) is included in the ZIP alongside its three modules and fixtures. It generates red-pipeline, overall-health, and top-level-project reports offline. It also exposes a read-only live adapter, whose deployment-specific assumptions require validation against your TeamCity server.

The implementation teaches the architecture rather than claiming exact visual or command-line equivalence with the original. It preserves the main health policy, bounded evidence, wildcard exclusions, and three report purposes. It deliberately changes timezone presentation to UTC, groups by IDs, validates links, and exposes incomplete scans. Those differences are described below so you can distinguish extraction from redesign.

## 12.1 Begin with executable acceptance behavior

Before arranging files, state what success means. A green latest build should yield green health and zero current red observations. A red prefix ending at a non-red build should yield its prefix count and oldest observed red time. An all-red window should retain uncertain-boundary wording. No builds should yield `OTHER` and `NO_BUILDS`. Failed retrieval should be a scan failure, not a healthy pipeline.

The application should generate all three views from one scan snapshot and one timestamp. HTML data should be encoded, links should use allowed schemes, and preview mode should avoid file effects. These requirements are specific enough to test independently of layout details.

There is one inherited policy to make explicit: `UNKNOWN` interrupts a red streak because the original treats every non-red status as a boundary. The reference analyzer preserves that behavior. If you later choose a stronger uncertainty policy, change a named rule and its tests rather than quietly modifying the loop during module extraction.

## 12.2 Inspect the package and run the offline application

```text
examples/ReferenceImplementation/
  New-TeamCityHealthReport.ps1
  fixtures.json
  TeamCityAPI/
    TeamCityAPI.psd1
    TeamCityAPI.psm1
  PipelineHealth/
    PipelineHealth.psd1
    PipelineHealth.psm1
  HTMLArtifact/
    HTMLArtifact.psd1
    HTMLArtifact.psm1
  output/
    Red.html
    Summary.html
    Projects.html
```

**Offline example 1 — run from the curriculum root.**

```powershell
$entry = Join-Path (Get-Location) 'examples/ReferenceImplementation/New-TeamCityHealthReport.ps1'
$result = & $entry -Offline
$result.WrittenPaths
$result.Scan | Select-Object Listed, Excluded, Eligible, IsComplete
$result.Scan.Rows | Select-Object PipelineId, Health, ObservedRedCount, BoundaryObserved
```

The fixture lists six configurations. Five are inspected and one history request deliberately fails. Among inspected rows, two are red, one green, and two other/no-build. The result is a partial scan, and every generated report displays that coverage. This is intentional evidence that partial results remain visible after the console is gone.

`Backend_Build` has `FAILURE, ERROR, SUCCESS`, so its observed red count is two and its boundary is known. `AllRed_Build` has two red observations and no boundary, so its report says “At least since.” `Empty_Build` has no history. `Unknown_Build` has an unknown status and an invalid optional date. Special characters in a pipeline name demonstrate HTML encoding.

The offline token is a fixed placeholder, and all requests are handled by an injected fixture transport. The application never sends it to a server. The same client request-validation and response-normalization code still runs, so the offline path exercises more than just the renderer.

## 12.3 Extract the pure analyzer first

Open [PipelineHealth.psm1](examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psm1). `Get-PipelineHealth` receives a newest-first array of normalized observations. It does not know a server, token, cache, file path, or HTML template. Its result contains classification and evidence, with no preformatted date labels.

**Offline example 2 — analyze a known boundary directly.**

```powershell
Import-Module './examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psd1' -Force
$history = @(
    [pscustomobject]@{ Status = 'FAILURE'; FinishedAt = [DateTimeOffset]::Parse('2026-11-12T14:00:00Z') }
    [pscustomobject]@{ Status = 'ERROR'; FinishedAt = [DateTimeOffset]::Parse('2026-11-11T14:00:00Z') }
    [pscustomobject]@{ Status = 'SUCCESS'; FinishedAt = [DateTimeOffset]::Parse('2026-11-10T14:00:00Z') }
)
$health = Get-PipelineHealth -NewestFirstBuilds $history
$health | Format-List
```

The loop initializes a no-build result, validates statuses, classifies the latest observation, and scans a leading red prefix only when the latest is red. `OldestObservedRedAt` is updated for each red observation. `BoundaryObserved` becomes true on the first non-red observation.

This extraction removes the original analyzer's HTTP and hierarchy work. The algorithm is now testable without mocking a client class. The input contract deliberately requires `FinishedAt` to exist on each normalized observation, although its value may be null. The adapter owns that normalization.

The result's `ObservedBuildCount` and `ObservedRedCount` describe evidence actually received. They do not claim the requested limit was reached. `BoundaryObserved` is a domain field; the renderer chooses the label from it. That separates meaning from English phrasing.

## 12.4 Introduce a stateful client where ownership helps

Open [TeamCityAPI.psm1](examples/ReferenceImplementation/TeamCityAPI/TeamCityAPI.psm1). The root module directly declares `TeamCityClient`, which owns its REST root, token, transport, and project cache. The class is useful here because these values belong to one connection lifetime.

The public factory `New-TeamCityClient` validates a server URI, normalizes the context path and REST suffix, checks the token, and constructs the client. Callers can dynamically import the module and use the factory without naming `[TeamCityClient]` in their own script. This avoids spreading parse-time class dependencies into every consumer.

The class's `Request()` method checks the destination before invoking the transport. It requires HTTPS, the configured host and port, and the REST-root path prefix; it rejects user information and fragments. The token reaches the transport only after that check. Continuations therefore cannot silently move authenticated requests to another host.

`hidden` reduces normal display of the token and transport, but it is not private access control. The client is a cooperative in-process component, not a secret vault. Stronger access control could be provided by a C# implementation while keeping the same public command interface.

## 12.5 Prove that the transport is replaceable

**Offline example 3 — inspect one request without networking.**

```powershell
Import-Module './examples/ReferenceImplementation/TeamCityAPI/TeamCityAPI.psd1' -Force
$observed = [Collections.Generic.List[string]]::new()
$transport = {
    param($uri, $token)
    $observed.Add($uri.AbsoluteUri)
    [pscustomobject]@{ buildType = @(); nextHref = '' }
}.GetNewClosure()
$token = ConvertTo-SecureString 'fixture-only' -AsPlainText -Force
$client = New-TeamCityClient -Server 'https://ci.example.com/teamcity/' -Token $token -Transport $transport
$items = @(Get-TeamCityBuildType -Client $client -PageSize 25)
"Items: $($items.Count)"
$observed
```

The result is zero items and one encoded request under `/teamcity/app/rest/buildTypes`. The callback receives a validated URI and a token object. It returns a response-shaped object, allowing the normal pagination code to run. The list records requests without leaking the token.

This injection boundary is intentionally small. The default transport uses `Invoke-RestMethod`, a 30-second timeout, JSON acceptance, bearer authentication, stop-on-error, and no redirects. It does not implement a full rate-limit or retry policy. Stage 3 provides the principles for adding one without hiding errors or multiplying attempts unexpectedly.

## 12.6 Preserve server continuations and bound the work

The private collection reader follows `nextHref`, detects repeated page URLs, limits total pages, validates required collection and ID fields, and deduplicates IDs. A short page does not imply completion if a continuation exists. History retrieval also stops after the application's observation limit.

The reader requests `nextHref` in field projections. It resolves relative continuation URLs against the current page, then delegates to `Request()` for destination checks. It never attaches credentials to a foreign-host continuation. These responsibilities belong together because pagination is part of the authenticated retrieval protocol.

The source's configuration pager increments offsets locally; the reference follows server URLs. The source reads one history response; the reference can continue until its limit. These are intentional robustness changes and need live comparison for the deployed TeamCity version.

The history locator preserves finished, nonpersonal, noncanceled selection with `defaultFilter:false`. It still has no explicit branch selector. The report states that scope plainly. Before adopting it for a default-branch health policy, add the server-supported branch dimension and verify known branch examples.

The client accepts only conservative simple external IDs. That prevents locator punctuation from changing the teaching query's grammar. It is a documented limitation, not a universal statement about valid TeamCity IDs. Extend it using documented escaping if your actual identifiers require more.

## 12.7 Normalize transport data before analysis

`Get-TeamCityBuildHistory` first obtains raw items, then checks status and constructs observations with `Id`, `Number`, `Status`, `FinishedAt`, and `WebUrl`. IDs become strings, statuses uppercase, and dates offset-aware instants or null. A malformed required status throws; an invalid optional date remains unknown.

The timestamp parser accepts the compact offset form, compact UTC form, and round-trip format used by this package. It intentionally does not replicate every permissive fallback of the original parser. If real server samples require additional forms, add exact supported formats and regression fixtures rather than relying on local culture.

The mapping is an anti-corruption boundary in practical terms: TeamCity's nested field names stop there, and the analyzer receives the smaller shape it needs. No HTML encoding occurs during mapping. Raw data stays usable by JSON or CSV consumers; output-context encoding happens later.

The client preserves API order. It does not silently sort by finish time because overlapping builds can make that a different order from the server's build sequence. The analyzer's newest-first precondition must be validated against the server behavior you intend to report.

## 12.8 Resolve hierarchy with bounded traversal

`Resolve-TeamCityTopProject` carries IDs and names together. It looks up each project through the per-client cache, stops before `_Root`, detects repeated IDs, and limits depth to one hundred. Unlike the source's name-only result, the output can support grouping by stable identity.

The entry script catches hierarchy failures separately from history failures. It retains the inspected pipeline's health, falls back to the immediate project identity, and increments `GroupingFallbacks`. The report displays that count. `IsComplete` describes health-inspection coverage; grouping quality is a separate measure.

This separation avoids discarding valid build evidence merely because a label lookup failed. A stricter organization might require verified grouping before publishing. That is application policy and can be changed at the entry boundary without rewriting the health algorithm.

## 12.9 Render from a complete snapshot

Open [HTMLArtifact.psm1](examples/ReferenceImplementation/HTMLArtifact/HTMLArtifact.psm1). `ConvertTo-PipelineReportHtml` accepts one scan envelope and a view choice. It shares a document shell, coverage notice, safe text encoding, UTC formatting, and chart helper across the three views.

The red view groups by immediate project ID and lists only red rows. The summary view shows aggregate health and an immediate-project table. The projects view groups by top-level ID and creates per-project charts. Names remain labels, so duplicate labels do not merge entities.

The chart uses counts to calculate numeric angles, formatted with invariant culture. Textual counts remain available alongside color. An empty dataset shows an explicit empty message rather than a misleading full pie. The chart itself is marked decorative because the adjacent text supplies the data.

Safe links require an absolute HTTPS URI without embedded user information, then HTML-encode the final URI and label. Invalid links become plain text. This allows ordinary HTTPS build links; it is not an organizational host allowlist. If your publishing context requires a host restriction, add that policy explicitly.

The implementation simplifies the original visual styling and omits some original row details, such as separate latest-build-number/link columns. It preserves the three report purposes and the main streak evidence, not every HTML byte or legacy property. For a production replacement, use the compatibility table and acceptance tests to restore any required fields deliberately.

## 12.10 Keep file writing separate and previewable

`Export-HtmlArtifact` receives a string and an exact destination. It calls `ShouldProcess` before writing. A temporary sibling file receives UTF-8 content, then `File.Move(..., overwrite: true)` replaces the destination. Cleanup removes a leftover temporary file if the operation fails.

This reduces exposure to a partially written destination, but replacement semantics depend on the filesystem and environment. It is not a universal crash-proof transaction. More importantly, three individually replaced files do not form one multi-file transaction. A staging directory plus a published index or directory switch is a separate design if readers need a consistent set.

**Offline example 4 — preview the whole workflow without creating a directory.**

```powershell
$entry = './examples/ReferenceImplementation/New-TeamCityHealthReport.ps1'
$previewDirectory = Join-Path ([IO.Path]::GetTempPath()) ('ReportPreview-' + [guid]::NewGuid())
$preview = & $entry -Offline -OutputDirectory $previewDirectory -WhatIf
$preview.Preview
Test-Path -LiteralPath $previewDirectory
```

The final values are `True` and `False`. Discovery and analysis still occur, but directory creation and report writes are previewed. That is the documented preview meaning. A live `-WhatIf` would still make read-only server requests, so it is not a “no networking” mode.

## 12.11 Make orchestration boring and accounting explicit

The entry script imports explicit manifests relative to itself, chooses live or offline transport, captures one generation instant, discovers configurations, applies exclusions, gathers histories, analyzes them, resolves project identities, and builds one scan envelope. It then renders all three strings before attempting writes.

Lists accumulate rows and failures. The accounting invariant is `Eligible = Rows.Count + Failures.Count`, while `Listed = Excluded + Eligible`. This prevents silently losing configurations after discovery. A required-field failure becomes an unavailable inspection rather than a healthy result.

The saved failure reason is deliberately sanitized to a safe category instead of copying arbitrary external exception text into HTML. A production application should add structured internal diagnostics, such as safe status and operation IDs, while keeping secrets and raw headers out of artifacts. The teaching implementation favors a small visible boundary over a complete logging framework.

The returned object contains the scan and paths actually written. The script does not choose a special process exit code for a partial scan; callers inspect `Scan.IsComplete` and apply their own CI policy. If you need the executable to fail a job on partial coverage, map that state to a documented exit code at the outermost wrapper.

## 12.12 Compatibility and deliberate changes

| Concern | Uploaded script | Teaching implementation |
|---|---|---|
| Red policy | FAILURE and ERROR | Preserved |
| Unknown interrupts streak | Yes | Preserved and tested |
| No builds | OTHER / NO_BUILDS | Preserved |
| All observed builds red | At least since | Preserved |
| Branch selector | None explicit | Preserved and disclosed |
| Name exclusions | Immediate names, wildcard | Preserved |
| Display timezone | Agent local time | UTC, explicitly labeled |
| Project grouping | Names | IDs with names displayed |
| Paging | Offset signal / one history response | Validated continuations, bounded history |
| Partial scan visibility | Console warnings | Persisted coverage and failures |
| Link handling | HTML encoding | Scheme validation plus encoding |
| Output | Legacy names and detailed layout | Red/Summary/Projects, simplified layout |

A compatibility wrapper can preserve old parameter names and output filenames while delegating to the new components. Do not call it drop-in until its fields, ordering, selection, and rendered content have been compared with real authorized fixtures and baseline reports.

## 12.13 Validate the transition with independent evidence

The package's verification runner parses scripts, executes marked offline examples in fresh processes, characterizes the original functions, runs focused Pester tests, validates manifests, and records chapter sizes. The reference tests cover health branches, pagination, unsafe continuations, hierarchy cycles and caching, HTML encoding, preview behavior, and the offline workflow.

The original characterization and new tests serve different purposes. Characterization records existing semantics. New tests protect the intended boundaries and named improvements. Their agreement on core streak cases gives confidence in extraction; their deliberate differences document redesign.

Live-server validation remains necessary for permissions, branch scope, ordering, retention, and server-version behavior. Start with a small known set and compare raw histories to both reports. Scale up only after the selection contract is correct. A complete offline suite cannot establish facts about a server it never contacted.

## 12.14 Extend the design without losing its clarity

If several consumers need stronger models, introduce a shared C# contracts assembly and map observations into immutable types. If requests need retries, add a classified bounded policy at the transport boundary. If HTML grows, separate shared document components from view templates. If scans become slow, measure request counts and cache effectiveness before introducing bounded parallel workers.

Each extension should preserve a simple flow: retrieve evidence, interpret evidence, render results, publish artifacts. The source script becomes understandable because those responsibilities have explicit inputs, outputs, and owners. That is the engineering capability the curriculum has been building toward: using PowerShell's command model, its object model, and .NET together to make a system easier to reason about and improve.

## 12.15 Carry out the migration in reviewable increments

The first increment can leave the original entry script and HTML intact while replacing only the analyzer's internal calculation with a pure function. Pass the already retrieved history into it and map its result back to the legacy row fields. Characterization fixtures should still agree. This establishes a useful seam without changing how users invoke the report.

The second increment moves request construction and execution into the client boundary. Keep the source's selection policy initially, but make configuration explicit. Add tests for encoded query values, context paths, and authentication destination checks. Compare a small authorized live sample before replacing the original retrieval path broadly.

The third increment extracts rendering behind explicit scan metadata. Start by preserving required content and column meanings. Shared helpers can remove repeated document shells and charts, but avoid redesigning every visual detail at the same time. Encoding and safe-link checks deserve independent fixtures because they protect different contexts.

The fourth increment introduces the scan envelope and makes unavailable inspections visible. This changes the reporting contract, so document the counts and denominator. A compatibility wrapper can still write the legacy filenames while the underlying model gains coverage information. Readers should understand why a report can contain no red rows and still be incomplete.

Only then consider broader policy changes such as default-branch-only selection or treating unknown observations as uncertainty gaps. Those changes alter what the report means. Give each a concrete before-and-after scenario and tests that express the intended new behavior.

## 12.16 Review the result from three perspectives

From the command user's perspective, setup and invocation should be clear. Required server and token inputs should not be buried in source edits. Output paths should identify real artifacts, preview mode should explain planned effects, and failures should produce a useful outcome rather than an indefinite prompt.

From the maintainer's perspective, the dependency graph should be easy to follow. The client owns connection state. The analyzer receives observations. The renderer receives results. The writer receives content and a destination. A change in one responsibility should not require understanding every other module before it can be tested.

From the report reader's perspective, labels must match evidence. “At least since” should survive bounded history. UTC should be visible. Grouping should use stable identity while showing friendly names. Partial scan coverage should remain visible in every view, including the red-only view where missing rows would otherwise be easiest to overlook.

These perspectives can reveal different defects. A technically correct analyzer is insufficient if the entry script is impossible to run unattended. A convenient command is insufficient if its artifact overstates coverage. A beautiful report is insufficient if its source selection does not match the intended branch policy.

## 12.17 Keep the next extension small and evidence-driven

If the application needs production retry behavior, add it at transport with a clear attempt budget and independent tests. If it needs exact multi-file publication, introduce staging and a reader-visible publication boundary. If it needs a stricter public model, move that contract into a versioned C# assembly. Each extension has a named reason and a place in the design.

Do not add all of these mechanisms merely because a larger system might need them someday. The current teaching package already demonstrates state ownership, modular loading, pure analysis, replaceable retrieval, safe rendering, previewable writes, and meaningful verification. Those are substantial engineering capabilities on which further requirements can build.

The final test of the architecture is practical: another engineer should be able to locate a rule, run its fixture, understand its result, and change it without accidentally sending requests or rewriting HTML. That is what makes the original report a useful learning project rather than merely a script to translate into class syntax.
