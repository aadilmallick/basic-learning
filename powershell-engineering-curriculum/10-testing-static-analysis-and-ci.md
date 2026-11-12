# Stage 10 — Testing, debugging, static analysis, and CI

Testing makes a refactor reviewable. It records what the code promises and catches specific ways that promise could break. Static analysis finds suspicious code patterns. Debugging explains one execution. CI runs selected checks repeatably. These tools complement each other; none proves the report is correct under every possible server condition.

This chapter teaches Pester 5 syntax deliberately, rather than relying on whichever Pester happens to ship with Windows. The bundled verification records the versions actually used. Offline examples marked as such need only PowerShell 7.4+; Pester examples require the setup described below. There are no quizzes or active-recall tasks.

## 10.1 Test behavior at the boundary where it matters

For a failure-streak analyzer, useful tests include a latest green build, a red streak followed by success, all-red bounded history, no builds, an unknown status, and malformed required data. These cases exercise different meanings. A test asserting only that a result is not null says little about correctness.

For an API client, useful tests include short pages with continuations, repeated continuations, foreign-host continuations, context-path preservation, invalid response shapes, and bounded history. For an HTML renderer, use special characters and unsafe URL schemes. For a writer, verify `-WhatIf` prevents a file effect.

Do not write a test that merely repeats the implementation's exact expression and calls the matching answer proof. Use independently understood scenarios and expected outcomes. The uploaded script supplies valuable characterization cases, but current behavior and desired future policy should be named separately.

## 10.2 Install and select a known test framework

The following is a **setup pattern**, not an offline example. It writes to your chosen tool directory and needs access to a configured package repository. Organizations may provide a private repository instead of PowerShell Gallery.

```powershell
# Setup pattern: choose your approved repository and tool location.
Save-Module -Name Pester -RequiredVersion 5.7.1 -Path './.tools' -Repository PSGallery
Save-Module -Name PSScriptAnalyzer -RequiredVersion 1.24.0 -Path './.tools' -Repository PSGallery
Import-Module './.tools/Pester/5.7.1/Pester.psd1' -Force
Import-Module './.tools/PSScriptAnalyzer/1.24.0/PSScriptAnalyzer.psd1' -Force
```

Saving tools locally avoids depending on an administrator-installed global copy. Pinning versions makes a lesson reproducible; it is not a claim that these are the latest releases. Select versions supported by your project and update them deliberately.

Pester 3, 4, 5, and later major releases have important differences. In particular, Pester 5 separates discovery from execution. Put runtime setup in `BeforeAll` or `BeforeEach`, and assertions inside `It`. The [Pester 5 test structure guide](https://pester.dev/docs/v5/usage/test-file-structure) and [discovery guide](https://pester.dev/docs/v5/usage/discovery-and-run) explain those phases.

## 10.3 A small pure function and a complete test file

Save the first block as `Get-ObservedRedCount.ps1` and the second as `Get-ObservedRedCount.Tests.ps1` in the same directory. These are a **paired-file example**; the test file is not a standalone ordinary script.

```powershell
function Get-ObservedRedCount {
    [CmdletBinding()]
    param([object[]]$Builds = @())
    $count = 0
    foreach ($build in $Builds) {
        if ($build.Status -notin @('FAILURE', 'ERROR')) { break }
        $count++
    }
    $count
}
```

```powershell
BeforeAll {
    . (Join-Path $PSScriptRoot 'Get-ObservedRedCount.ps1')
}
Describe 'Get-ObservedRedCount' {
    It 'stops at the first non-red build' {
        $builds = @(
            [pscustomobject]@{ Status = 'FAILURE' }
            [pscustomobject]@{ Status = 'ERROR' }
            [pscustomobject]@{ Status = 'SUCCESS' }
            [pscustomobject]@{ Status = 'FAILURE' }
        )
        Get-ObservedRedCount -Builds $builds | Should -Be 2
    }
    It 'returns zero for no observations' {
        Get-ObservedRedCount -Builds @() | Should -Be 0
    }
    It 'returns zero when the latest build is green' {
        Get-ObservedRedCount -Builds @(
            [pscustomobject]@{ Status = 'SUCCESS' }
        ) | Should -Be 0
    }
}
```

Run `Invoke-Pester -Path ./Get-ObservedRedCount.Tests.ps1 -Output Detailed`. Each `It` names an observable behavior. The first case deliberately includes an older failure after success so a mistaken “count all failures” implementation would fail. That is stronger evidence than a fixture containing only two red builds.

The empty-array test also protects output cardinality. The function must return integer zero, not no objects. Callers should not confuse “calculated zero” with “no result.” A focused test can assert the count and type when that distinction is part of the public contract.

## 10.4 Data-driven tests cover policy variations

Use data-driven cases when the same rule applies to several values. Keep the test body readable and put genuinely different scenarios in separate tests. Pester 5's discovery phase means case generation belongs in the correct phase, not in arbitrary runtime variables outside setup blocks.

The following is a **Pester test fragment** suitable inside a test file that has imported the relevant function:

```powershell
It 'classifies <Status> as <Expected>' -TestCases @(
    @{ Status = 'SUCCESS'; Expected = 'GREEN' }
    @{ Status = 'FAILURE'; Expected = 'RED' }
    @{ Status = 'ERROR'; Expected = 'RED' }
    @{ Status = 'UNKNOWN'; Expected = 'OTHER' }
) {
    param($Status, $Expected)
    Get-HealthInterpretation -RawStatus $Status |
        Select-Object -ExpandProperty Health |
        Should -Be $Expected
}
```

These cases document local policy, including `ERROR` compatibility. They do not prove what a live server emits. A separate integration test can inspect known server responses and validate the adapter against them. Keeping the two test kinds separate prevents a server outage from masquerading as a domain-logic regression.

## 10.5 Mock commands at the boundary where they are resolved

A mock replaces a command with controlled behavior during a test. If a module calls a private HTTP helper, install the mock in that module's scope. Mocking a similarly named command in the caller's scope may not affect the module's resolution.

The following is a **Pester module-test pattern**, showing the intended boundary rather than a complete test suite:

```powershell
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../TeamCityAPI/TeamCityAPI.psd1') -Force
}
Describe 'Transport boundary' {
    It 'passes authentication to the HTTP adapter without contacting a server' {
        Mock Invoke-RestMethod -ModuleName TeamCityAPI {
            [pscustomobject]@{ buildType = @(); nextHref = '' }
        }
        $token = ConvertTo-SecureString 'fixture-token' -AsPlainText -Force
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token $token
        @(Get-TeamCityBuildType -Client $client).Count | Should -Be 0
        Should -Invoke Invoke-RestMethod -ModuleName TeamCityAPI -Times 1 -Exactly
    }
}
```

The module and command names match the bundled teaching implementation. A mock intercepts PowerShell command invocation; it does not automatically replace arbitrary .NET instance methods. If essential behavior is hidden inside a .NET call, inject a transport or wrap the call in a narrow function instead of attempting to mock every internal detail.

Use parameter filters when the argument is part of the behavior being verified. Do not overspecify incidental details such as hashtable key order. A test that fails whenever harmless implementation structure changes makes refactoring harder without protecting the user. See [Pester 5 mocking](https://pester.dev/docs/v5/usage/mocking) for module scope and call assertions.

## 10.6 Test effects with temporary destinations

Pester's `$TestDrive` supplies an isolated test location for filesystem checks. An artifact writer test should prove that `-WhatIf` prevents creation and that a real write contains the expected UTF-8 content. It should not write into a developer's documents directory.

**Offline example 1 — a dependency-free assertion for the same idea.**

```powershell
function Export-PreviewText {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Path, [string]$Text)
    if ($PSCmdlet.ShouldProcess($Path, 'Write text')) {
        [IO.File]::WriteAllText($Path, $Text)
    }
}
$path = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.txt')
Export-PreviewText -Path $path -Text 'example' -WhatIf
if (Test-Path -LiteralPath $path) { throw 'Preview unexpectedly wrote a file.' }
'Preview left no artifact'
```

This tiny assertion needs no test framework and verifies a meaningful user promise. The bundled verification uses both executable examples and focused tests, reporting each separately. A lack of Pester should not prevent basic offline verification, but it should not lead to claiming a Pester suite ran when it did not.

## 10.7 Characterization tests preserve behavior before redesign

Characterization records what existing code does for controlled input. It is especially valuable when documentation and implementation differ. The original report says a green build establishes the boundary, but the loop actually stops at any non-red status. A fixture containing `FAILURE, UNKNOWN, FAILURE` exposes that distinction.

Extracting function definitions through the parser allows offline characterization without executing the original script's top-level token prompt, HTTP requests, or file writes. Stage 11 explains the extraction and its trust assumptions. These tests are local evidence of source behavior, not an endorsement of every policy.

When the new analyzer intentionally changes a rule, update a separately named desired-behavior test and document the change. Do not silently alter characterization expectations until the old and new implementations happen to agree. That would erase the evidence the test was intended to preserve.

## 10.8 Static analysis checks patterns, not business truth

`Invoke-ScriptAnalyzer` can flag unapproved verbs, unused variables, problematic patterns, and compatibility concerns. It cannot infer whether your chart's denominator excludes failed scans or whether your locator covers the intended branches. Treat findings as specific questions to resolve.

A **tooling pattern** for the extracted implementation is:

```powershell
$findings = Invoke-ScriptAnalyzer -Path './examples/ReferenceImplementation' -Recurse
$findings | Select-Object RuleName, Severity, ScriptName, Line, Message
if (@($findings | Where-Object Severity -eq 'Error').Count) {
    throw 'Static analysis reported errors.'
}
```

Choose rules and severities in project configuration. If you suppress a rule, explain why at the narrowest useful scope. A token parameter typed as `SecureString` may satisfy one rule, while the overall secret-handling design still needs review. Conversely, a deliberately private helper may trigger a naming rule without being a user-facing API problem.

The [PSScriptAnalyzer overview](https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview) describes its scope. Report actual findings and selected policy; do not summarize “no errors” as “no defects.”

## 10.9 Debug from the smallest reproducible input

For a wrong streak date, save the ordered observations and run the analyzer alone. Inspect each iteration's status, count, and oldest red candidate. For a missing configuration, inspect pagination requests and continuations. For malformed HTML, inspect the model and encoded output independently.

Use breakpoints in an editor or `Set-PSBreakpoint` for a focused function. `Write-Debug` can expose intermediate decisions without contaminating success output. `Trace-Command -Name ParameterBinding` helps explain unexpected binding, but traces can be verbose and may include argument values. Keep credentials out of captured diagnostics.

`Get-PSCallStack` identifies the execution path. `$Error[0]` can show the latest error in an interactive session, but it is mutable session history, not a durable application result. Capture the relevant error record inside the catch handling that owns it.

## 10.10 CI should reproduce the user's package

A useful CI sequence starts a clean PowerShell process, installs pinned tools from an approved source, validates manifests, parses scripts, runs offline examples and domain tests, runs selected static analysis, and packages the verified files. Run live integration checks separately with explicit secrets and safe read-only scope.

Make failure visible to the CI runner. `Invoke-Pester -PassThru` returns a result object; inspect `FailedCount` and exit nonzero when needed, or use the framework's CI behavior deliberately. Avoid a script that writes a red error message but returns process code zero.

Publish useful test evidence: runtime version, test totals, failures, and artifacts such as fixture-generated HTML. Do not publish secrets or arbitrary response dumps. Record enough context to distinguish a language regression, a packaging mistake, and an external server outage.

## 10.11 Test invariants and side effects, not just examples

Examples protect representative scenarios. Invariants protect relationships that should hold across many scenarios. For a scan, listed equals excluded plus eligible; eligible equals inspected plus failed. For a summary, green plus red plus other equals total inspected. For a current streak, red count cannot exceed observed build count.

These checks are useful inside tests and sometimes as runtime guards at a boundary. They should not merely duplicate the implementation's arithmetic in a way that shares the same mistaken denominator. Construct fixtures with excluded and failed cases so a wrong accounting model cannot accidentally pass.

Input mutation is another valuable property. A pure analyzer should not reorder history or change statuses while interpreting them. A renderer should not overwrite raw names with HTML-encoded names, because later CSV output would then contain markup entities. Save a small input projection before and after, or assert selected fields remain unchanged.

**Offline example 2 — an independent input-preservation check.**

```powershell
Import-Module './examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psd1' -Force
$history = @(
    [pscustomobject]@{ Status = 'FAILURE'; FinishedAt = $null }
    [pscustomobject]@{ Status = 'SUCCESS'; FinishedAt = $null }
)
$before = @($history | ForEach-Object Status) -join ','
$result = Get-PipelineHealth -NewestFirstBuilds $history
$after = @($history | ForEach-Object Status) -join ','
if ($before -cne $after) { throw 'Analyzer mutated its input.' }
if ($result.ObservedRedCount -gt $result.ObservedBuildCount) { throw 'Invalid streak count.' }
'Input and count invariants held'
```

Coverage metrics can identify unexecuted branches, but high coverage does not establish good assertions. A test can execute the wrong denominator calculation and still pass if it never checks the result. Favor a small set of discriminating cases over a large set of near-identical ones.

Fresh-process tests also protect against hidden session dependencies. A loaded class from yesterday can make today's broken import appear healthy. A module cache can make a missing fixture request disappear. Separate tests that intentionally verify cache reuse from tests that need a new client, and run the final package from a clean process.

Treat test failures as evidence to investigate, not instructions to change expected values until the suite is green. Revisit the contract, inspect the fixture, and decide whether the implementation or expectation is wrong. That habit is central to preserving behavior during refactoring.

## 10.12 Verification claims must match evidence

Parsing proves syntax under the parser used. Executing a snippet proves that one path worked with that input and runtime. A focused test protects a stated behavior. A live comparison checks assumptions about one server. A ZIP integrity check verifies packaging bytes. These are distinct claims.

This edition includes a verification report with chapter sizes, executed examples, reference tests, source characterization, and tool versions. It also states the remaining live-server limits. That makes the curriculum's technical confidence reviewable without claiming that every possible deployment has been validated.

The practical outcome is a refactoring workflow you can trust: preserve known behavior, isolate rules, test the boundaries, and let CI repeat the checks. The next two chapters apply that workflow directly to the uploaded report rather than substituting an unrelated toy project.

## 10.13 Diagnose a failing test before editing the expectation

Suppose the known-boundary test expected two red builds but received three. Start with the input sequence and the rule: only the leading red prefix counts. If the fixture is `FAILURE, ERROR, SUCCESS, FAILURE`, counting three probably means the implementation counted all failures instead of stopping at success. The test is doing useful work; changing the expected count would erase the rule.

Now suppose the same test receives no result. Inspect whether the function wrote output, returned early, or threw. A method call may have failed during date parsing, or the function may have accidentally used a formatting command. Type and cardinality diagnostics from stage 1 remain valuable inside tests.

If the test passes alone but fails in the suite, investigate shared state: module caches, mutable fixtures, loaded types, environment changes, and mock lifetime. Do not immediately add sleeps. Time-based delays rarely fix a deterministic state leak. Create fresh clients and fixtures unless reuse is the behavior under test.

If the suite passes interactively but fails in CI, compare runtime versions, module paths, working directory, profiles, locale, and filesystem assumptions. A relative path that depends on the terminal's current directory is a common cause. Anchor implementation paths to the test or script location, and explicitly set the working directory when demonstrating copyable chapter snippets.

A good failure message identifies the scenario and the violated contract. “Expected 2 but got 3” becomes more useful when the test name says “counts only the current red prefix.” Name tests after behavior so their output becomes a readable specification.

## 10.14 Use mocks to isolate effects, not to imitate the whole implementation

A mock can return a controlled response, throw a chosen exception, or record an invocation. These uses correspond to different questions. A response fixture checks interpretation. A thrown timeout checks recovery. An invocation assertion checks whether a required effect occurred or an unsafe effect was prevented.

For a foreign continuation test, the most important assertion is that the transport was called only for the approved first page. Merely asserting that an exception occurred is weaker: an implementation could send credentials to the foreign host and then fail afterward. The call-count assertion protects the actual boundary.

For preview mode, assert the filesystem remains unchanged. A mock asserting that a helper was not called may be useful, but checking the user-visible effect is stronger when practical. The implementation could bypass that helper and write through another path. Temporary destinations let you test the actual promise safely.

Avoid building a fake response generator that duplicates the client's URI parser line for line. If both share the same error, tests may pass while the protocol is wrong. Use simple, independently specified pages and inspect selected decoded query fields. Keep fixtures small enough that a reader can see why the expected result follows.

Do not mock the function whose behavior you are trying to verify. Mocking `Get-PipelineHealth` while testing its own streak rule proves nothing. Mock its external dependency when testing orchestration, and test the real analyzer directly with data. This separation keeps each test focused on one responsibility.

## 10.15 Build a layered verification strategy

The fastest layer parses code and validates manifests. It catches missing braces, invalid declarations, and packaging metadata problems before any business workflow runs. This layer is valuable but limited: a syntactically valid function can still use the wrong denominator or query the wrong branch.

The next layer executes small offline examples. These check language behavior and the teaching snippets themselves, including C# compilation and class loading. Running them in fresh processes prevents definitions from one example from accidentally making another work. Their expected outputs are explained in the chapters so the reader understands what was observed.

Focused unit tests then protect domain and boundary behavior. They use discriminating fixtures, assert uncertainty, and check prohibited effects. The reference suite deliberately includes partial coverage, invalid dates, and unsafe continuations rather than testing only the happy path.

An offline integration layer runs the whole modular application with a fake transport and real normalization, analysis, rendering, and writing. This catches mismatched property names and packaging errors between modules. A unit test for each component can pass while the components disagree about a field, so the end-to-end fixture remains important.

Live integration checks come last and stay separate. They validate server selection, permissions, response shape, and ordering. Their failures may be environmental, so report them distinctly from deterministic regressions. Use the smallest authorized scope that can establish the external assumptions you need.

## 10.16 Keep verification evidence reviewable

A useful report states versions, counts, failures, skips, and limits. It does not simply say “tested.” If Pester was unavailable, say which dependency-free checks ran. If the server was not contacted, say the adapter was tested against fixtures. If only one operating system was executed, do not imply cross-platform validation.

Retain machine-readable results alongside a concise human explanation. The JSON supports inspection and automation; the Markdown explains what the checks mean. A checksum manifest can connect those results to the packaged files. This is especially useful when transferring a curriculum or tool out of the original chat environment.

Re-run checks when implementation changes, failures are fixed, or unresolved assumptions require new evidence. Do not repeatedly broaden testing without a reason once the relevant checks pass. The purpose is confidence in a concrete result, not an ever-growing ritual that delays delivery.
