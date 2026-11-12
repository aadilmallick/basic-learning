# Stage 12: Guided Refactoring and Reference Architecture

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Goal and acceptance criteria
Transform the monolith into reusable modules while preserving the three HTML reports and their documented semantics. The final CLI should be short: validate inputs, create client, fetch data, analyze, render, write, and report errors. Never publish employer-specific credentials or internal report data in a personal repository.

### Proposed repository
```text
powershell-teamcity-health/
  README.md
  src/
    TeamCityAPI/
      TeamCityAPI.psd1
      TeamCityAPI.psm1
      Public/New-TeamCityClient.ps1
      Public/Get-TeamCityBuildType.ps1
      Public/Get-TeamCityBuildHistory.ps1
      Private/Invoke-TeamCityRequest.ps1
      Private/Get-TeamCityProjectInfo.ps1
    PipelineHealth/
      PipelineHealth.psd1
      PipelineHealth.psm1
      Public/Get-PipelineHealth.ps1
      Private/Get-RedStreak.ps1
    HTMLArtifact/
      HTMLArtifact.psd1
      HTMLArtifact.psm1
      Public/ConvertTo-RedPipelineHtml.ps1
      Public/ConvertTo-SummaryHtml.ps1
      Public/ConvertTo-ProjectChartHtml.ps1
      Private/ConvertTo-HtmlSafeText.ps1
  scripts/New-TeamCityHealthReport.ps1
  tests/
    Unit/
    Integration/
  docs/
```
Names are a target design, not claims that these files already exist. Start with function modules; introduce classes only for models/client state where the tradeoff is favorable.

### Refactoring sequence
**Step 1 — Baseline:** preserve an authorized copy of the original script; capture expected report metrics with sanitized fixtures. Write Pester tests for streaks, empty responses, project grouping, and HTML encoding. Do not begin by changing all code at once.

**Step 2 — Pure functions:** extract `ConvertFrom-TeamCityDate`, `Test-NameExcluded`, and health calculations. Give each explicit inputs and documented output types. Keep their behavior stable.

**Step 3 — API module:** move URI construction, GET calls, build-type pagination, build history, and project cache into `TeamCityAPI`. Replace ambient `$headers`/`$apiRoot` with a client configuration object. Add HTTP error contracts and injectable transport for tests.

**Step 4 — Health module:** normalize API DTOs and return canonical pipeline results. Avoid preformatted date strings in the model. Return a scan summary that includes failures and completeness.

**Step 5 — HTMLArtifact:** separate the shared HTML shell/CSS from the three report bodies. Encode all untrusted visible text; validate hyperlink schemes; render from supplied rows and a supplied timestamp. Keep rendering free of network calls.

**Step 6 — Orchestrator:** import modules and connect them with explicit parameters. Keep `Write-Progress` in orchestration, not analysis. Use one `GeneratedAt` value for all reports. Use temporary output files and clear errors on write failure.

**Step 7 — Verify:** run unit tests, integration tests against a controlled mock or approved test server, static analysis, and a comparison of normalized metrics and HTML content. Check zero/one/many build types, all status cases, and timezone formatting.

### Example pure domain function
```powershell
function Get-RedStreak {
    [CmdletBinding()]
    param([Parameter(Mandatory)][object[]]$Builds)
    $red = 0
    $oldestObserved = $null
    $foundNonRed = $false
    foreach ($build in $Builds) {
        if ($build.Status -notin @('FAILURE','ERROR')) {
            $foundNonRed = $true
            break
        }
        $red++
        $oldestObserved = $build
    }
    [pscustomobject]@{
        Count=$red
        OldestObservedRedBuild=$oldestObserved
        IsLowerBound=($red -gt 0 -and -not $foundNonRed)
    }
}
```
This assumes the input is ordered newest first and is a bounded history. `IsLowerBound` means the available history did not show the preceding non-red build; it does not prove the pipeline has never been green.

### Example HTML boundary
```powershell
function ConvertTo-HtmlSafeText {
    [CmdletBinding()]
    param([AllowNull()][object]$Value)
    [Net.WebUtility]::HtmlEncode([string]$Value)
}
function Test-SafeReportLink {
    param([string]$Url)
    $parsed = $null
    if (-not [uri]::TryCreate($Url,[UriKind]::Absolute,[ref]$parsed)) { return $false }
    $parsed.Scheme -in @('https','http')
}
```
Encode URL attribute values **after** checking the scheme; HTML encoding alone does not make `javascript:` URLs safe. For private internal dashboards, you may additionally restrict link hosts.

### CLI boundary design
```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$TeamCityUrl,
    [ValidateRange(1,500)][int]$MaxBuildsToScan=100,
    [string]$OutputDirectory='.'
)
# Import known module manifests relative to $PSScriptRoot.
# Obtain credentials through an approved secret mechanism.
# Build client -> discover -> analyze -> render -> write.
# This is intentionally a scaffold, not a drop-in replacement.
```
A complete production entry point requires the actual exported module contracts and verified TeamCity response schemas. Do not misrepresent this scaffold as a tested replacement for the original.

### Release checklist
- All three report variants produced with consistent timestamps.
- Counts reconcile and partial failures are visible.
- Red streak lower-bound wording is correct.
- Pagination terminates without skipped/duplicated items.
- Output is encoded and links are validated.
- No token appears in logs, files, tests, or repository history.
- Pester and PSScriptAnalyzer pass on supported PowerShell versions.
- README documents install, imports, configuration, CLI parameters, and limitations.

### Architectural finish line
The user can replace TeamCity with a fake provider in tests, add another report format without editing the API client, and change API request behavior without editing HTML. That is the practical meaning of modularity—not simply having more files.
