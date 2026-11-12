# Stage 10: Testing, Static Analysis, and CI

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Tests protect behavior while structure changes
Refactoring without characterization tests can silently change the report. Begin with deterministic examples of green, red, no builds, mixed statuses, missing dates, API errors, and project hierarchy traversal.

### Install tools
```powershell
Install-Module Pester -Scope CurrentUser -MinimumVersion 5.0
Install-Module PSScriptAnalyzer -Scope CurrentUser
Import-Module Pester
```
On managed workstations, use an approved internal repository instead of assuming PowerShell Gallery access. Confirm versions with `Get-Module -ListAvailable`.

### Pester 5 example
Save `PipelineHealth.Tests.ps1` beside a file containing `Get-RedStreakCount`:
```powershell
BeforeAll {
    . "$PSScriptRoot/PipelineHealth.ps1"
}
Describe 'Get-RedStreakCount' {
    It 'counts the contiguous newest red builds' {
        $builds = @(
            [pscustomobject]@{Status='FAILURE'},
            [pscustomobject]@{Status='ERROR'},
            [pscustomobject]@{Status='SUCCESS'},
            [pscustomobject]@{Status='FAILURE'}
        )
        Get-RedStreakCount -Builds $builds | Should -Be 2
    }
    It 'returns zero for a green latest build' {
        Get-RedStreakCount -Builds @([pscustomobject]@{Status='SUCCESS'}) | Should -Be 0
    }
}
```
`BeforeAll` loads code in the test container; `Describe` groups behavior and `It` names a single expectation. Keep tests independent of the live TeamCity server.

### Mock external calls
In Pester, `Mock` replaces commands within the applicable scope. A unit test of an API wrapper can mock `Invoke-RestMethod`, return a known JSON-shaped object, and assert request parameters using `Should -Invoke`. Module-scoped commands may require `-ModuleName` so the mock applies where the command is resolved. Test the behavior, not incidental implementation details.

### Static analysis
```powershell
Invoke-ScriptAnalyzer -Path './src' -Recurse -Severity Warning,Error
Invoke-Pester -Path './tests' -CI
```
Static analysis catches common issues but does not prove runtime correctness. Add formatting and lint rules gradually so warnings are actionable.

### CI contract
A GitLab CI or TeamCity job should install pinned dependencies, run analyzer and Pester, produce test results, and fail on meaningful test failures. Keep live integration tests separate, opt-in, and credential-protected. Do not publish real report HTML containing internal project names in a public artifact repository.

### Test matrix for this script
| Case | Expected behavior |
|---|---|
| No builds | OTHER / NO_BUILDS |
| Latest SUCCESS | GREEN, streak 0 |
| FAILURE, ERROR, SUCCESS | RED, streak 2, exact observed start |
| FAILURE through scan limit | RED, streak lower bound |
| Project lookup fails | documented fallback and warning |
| API request fails for one pipeline | partial scan counted explicitly |
| HTML special characters | encoded visible text |
| Zero pipelines | valid empty report and zero totals |

### Quality gates
Prefer tests that establish invariants: red+green+other equals inspected count; affected project count is based on distinct project identifiers when names collide; percentages are based on a documented denominator; HTML outputs are UTF-8 and nonempty.
