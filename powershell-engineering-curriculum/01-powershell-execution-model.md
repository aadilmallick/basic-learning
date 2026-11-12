# Stage 1: PowerShell Execution Model

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## The problem: shell commands are not ordinary functions
PowerShell is both a shell and a .NET language. Commands exchange *objects* on the success stream, not formatted screen text. Formatting happens at the presentation boundary. Understanding this prevents bugs in report generation and module interfaces.

### Types, objects, and the Extended Type System
```powershell
$process = Get-Process -Id $PID
$process.GetType().FullName
$process | Get-Member
$process | Select-Object Name, Id, CPU
```
`Get-Member` reveals adapted and extended members; `Select-Object` creates a projected object rather than mutating the process. PowerShell can access .NET members with `.` and static members with `::`:
```powershell
[Math]::Round(12.345, 2)
[DateTimeOffset]::UtcNow
[Net.WebUtility]::HtmlEncode('<script>')
```
The last expression is the same encoding API used in the supplied HTML report.

### Arrays, enumeration, and output cardinality
```powershell
function Get-SampleBuilds { 'A'; 'B' }
$many = @(Get-SampleBuilds)
$one = @('A')
$empty = @()
"$($many.Count), $($one.Count), $($empty.Count)"
```
PowerShell unrolls many collections written to the success stream. `@(...)` guarantees the caller receives an array; the unary comma `,$array` can prevent enumeration when emitting a collection as one object. A function returning a single item may otherwise appear scalar. This is why the original script uses `@(Get-RecentFinishedBuilds ...)`.

### Success output versus diagnostics
```powershell
function Get-HealthyCount {
    [CmdletBinding()]
    param([object[]]$Builds)
    Write-Verbose 'Counting successful builds'
    @($Builds | Where-Object Status -eq 'SUCCESS').Count
}
Get-HealthyCount -Builds @([pscustomobject]@{Status='SUCCESS'}) -Verbose
```
`Write-Output` and bare expressions produce pipeline data. `Write-Verbose`, `Write-Warning`, `Write-Information`, and `Write-Error` have distinct purposes. `Write-Host` is presentation-oriented, not a return value. Avoid logging with bare strings inside data-producing functions.

### Scope and closures
```powershell
$baseUrl = 'https://ci.example.test'
function Get-ImplicitUrl { "$baseUrl/app/rest" }
function Get-ExplicitUrl { param([string]$BaseUrl) "$($BaseUrl.TrimEnd('/'))/app/rest" }
```
The first function silently depends on parent scope; the second exposes the dependency. Script, module, local, global, and private scopes influence name resolution. Prefer explicit parameters or instance state over mutable global variables. `Set-StrictMode -Version Latest` catches many undefined-variable and missing-property mistakes but does not replace tests.

### Hashtable, PSCustomObject, class
```powershell
$headers = @{ Accept='application/json' }
$build = [pscustomobject]@{ Id=10; Status='FAILURE' }
$build.PSObject.Properties['Status'].Value
```
Hashtables are excellent for headers and query maps. `PSCustomObject` is useful for lightweight data transfer and reporting. Classes become valuable when a stable model needs typed state and behavior. JSON returned by `Invoke-RestMethod` is often `PSCustomObject`; inspect it rather than assuming every property exists.

### Pipeline semantics and performance
`Where-Object` streams objects and composes naturally; `@($items | Where-Object ...)` materializes results. In a hot loop, repeated `+=` on arrays can allocate new arrays; a `[System.Collections.Generic.List[object]]` is more efficient for accumulation.
```powershell
$list = [System.Collections.Generic.List[object]]::new()
$list.Add([pscustomobject]@{Id=1; Status='SUCCESS'})
$list.Add([pscustomobject]@{Id=2; Status='FAILURE'})
$list.ToArray() | Where-Object Status -eq 'FAILURE'
```
**Connection to source:** the report's `$allPipelines += $pipelineInfo` and `$redPipelines += $pipelineInfo` can be changed to lists without changing report behavior. Keep the return contract stable while optimizing internals.

### Design takeaway
Before creating a module, specify what each command emits, whether it emits zero/one/many items, which output stream carries diagnostics, and which values are injected instead of read from surrounding scope.
