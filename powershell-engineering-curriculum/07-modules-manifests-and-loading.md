# Stage 7: Modules, Manifests, and Loading

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Packaging versus architecture
A module packages related commands and types. Splitting a script into `.psm1` files does not automatically remove coupling: public contracts, dependency direction, and initialization still matter.

### Minimal function module
Directory:
```text
TeamCityAPI/
  TeamCityAPI.psd1
  TeamCityAPI.psm1
  Public/Get-TeamCityApiRoot.ps1
```
`Public/Get-TeamCityApiRoot.ps1`:
```powershell
function Get-TeamCityApiRoot {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ServerUrl)
    "$($ServerUrl.TrimEnd('/'))/app/rest"
}
```
`TeamCityAPI.psm1`:
```powershell
. "$PSScriptRoot/Public/Get-TeamCityApiRoot.ps1"
Export-ModuleMember -Function Get-TeamCityApiRoot
```
Create the manifest:
```powershell
New-ModuleManifest -Path './TeamCityAPI/TeamCityAPI.psd1' `
    -RootModule 'TeamCityAPI.psm1' -ModuleVersion '0.1.0' `
    -Guid ([guid]::NewGuid()) -Author 'Learning Project' `
    -FunctionsToExport @('Get-TeamCityApiRoot')
```
Import and inspect:
```powershell
Import-Module ./TeamCityAPI/TeamCityAPI.psd1 -Force
Get-Command -Module TeamCityAPI
Get-TeamCityApiRoot -ServerUrl 'https://ci.example.test'
```
The manifest is metadata and a load contract. Explicit exports improve discoverability and reduce accidental API expansion.

### Dynamic loading versus class parse time
`Import-Module` executes at runtime and can load modules dynamically. `using module` is parsed early and is needed when a script directly references a PowerShell class type defined in another module. It must appear before executable statements and cannot be dynamically constructed from a variable. This means fully dynamic class loading and static type annotations do not mix freely.

**Practical compromise:** expose a `New-TeamCityClient` factory and commands that accept `[object]` or a compiled interface at module boundaries. The consumer can dynamically import the module and use the returned object without spelling its PowerShell class type. For fixed dependencies, prefer `using module` and explicit manifest requirements.

### Dependencies and versioning
Use `RequiredModules` in manifests for declared dependencies; avoid circular imports. Public functions should remain backward compatible within a version policy. A module's exported commands are its API; private helpers may change without breaking callers.

### Module design for the report
```text
PowerShellTeamCityReports/
  src/
    TeamCityAPI/TeamCityAPI.psd1
    PipelineHealth/PipelineHealth.psd1
    HTMLArtifact/HTMLArtifact.psd1
  scripts/New-TeamCityHealthReport.ps1
  tests/
  docs/
```
The data path is API → health analysis → HTML renderer. The renderer should not call TeamCity. The analyzer should not write files. The entry point imports modules, passes inputs, and writes outputs.

### Common module mistakes
Avoid unbounded dot-sourcing from unknown directories; avoid exporting every function; avoid global variables for configuration; avoid relying on the current working directory instead of `$PSScriptRoot`; avoid hardcoding company endpoints in reusable libraries; and do not use `Import-Module -Force` as a substitute for clear class reload behavior. Restart a session when changing PowerShell class definitions.

### Distribution
Place modules on `$env:PSModulePath`, install from a trusted repository, or import by explicit manifest path. Keep the repository independent of the employer's infrastructure and do not publish proprietary URLs, tokens, pipeline names, or report data.
