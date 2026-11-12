# Stage 8: Software Design and Dependency Injection

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Architecture begins with change
Ask: if the TeamCity API changes, what must change? If report HTML changes, what must change? If a new output format is needed, what must change? Good architecture localizes each answer.

### Cohesion and coupling
Cohesion means related behavior lives together. Coupling means one component knows details about another. `Invoke-TeamCityGet` should know HTTP, not HTML. `New-ReportHtml` should know markup, not bearer tokens. A health analyzer should know status rules, not file paths.

### Functional core, imperative shell
A particularly effective PowerShell design puts pure computations in functions and effects at the edges:
```powershell
function Get-RedStreakCount {
    [CmdletBinding()]
    param([Parameter(Mandatory)][object[]]$Builds)
    $count = 0
    foreach ($build in $Builds) {
        if ($build.Status -notin @('FAILURE','ERROR')) { break }
        $count++
    }
    $count
}
$sample = @(
    [pscustomobject]@{Status='FAILURE'},
    [pscustomobject]@{Status='ERROR'},
    [pscustomobject]@{Status='SUCCESS'}
)
Get-RedStreakCount -Builds $sample
```
This function has no network or filesystem dependencies and is straightforward to test. Its precondition is that builds are ordered newest first; document and validate ordering at the boundary.

### Dependency injection in PowerShell
```powershell
function Get-ReportRows {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$FetchBuilds,
        [Parameter(Mandatory)][string]$BuildTypeId
    )
    $builds = @(& $FetchBuilds $BuildTypeId)
    [pscustomobject]@{ BuildTypeId=$BuildTypeId; RedStreak=Get-RedStreakCount -Builds $builds }
}
$fakeFetch = { param($id) [pscustomobject]@{Status='FAILURE'} }
Get-ReportRows -FetchBuilds $fakeFetch -BuildTypeId 'Backend_Build'
```
This illustrates injecting the *operation* rather than hardcoding an API call. In production, a client method or function can supply it. Do not use injection everywhere; apply it at external-effect boundaries that need substitution.

### Contracts and models
Define a stable `PipelineHealthResult`: build type ID, project ID, latest status, streak count, earliest observed failure timestamp, `IsStreakBounded`, and scan error state. Prefer storing canonical data and deriving display text in the renderer; otherwise date text and date values can disagree.

### Design tradeoffs
| Design | Benefit | Cost |
|---|---|---|
| Single script | Easy to start | Difficult reuse/testing |
| Function modules | Idiomatic, composable | Requires careful state boundaries |
| PowerShell classes | Typed state and behavior | Class loading/version constraints |
| C# library | Strong contracts, cross-.NET reuse | Build tooling and compatibility |

### Test seams
The external seams are HTTP calls, clock/timezone, filesystem writes, and rendering. Pure analysis should be independent of all four. This lets a test use fixed build history and compare exact health results.

### Practical guidance
Prefer composition to inheritance, explicit inputs to ambient state, a small public API to exposing implementation details, and deliberate duplication over premature abstraction. Refactor only after characterizing current behavior with tests.
