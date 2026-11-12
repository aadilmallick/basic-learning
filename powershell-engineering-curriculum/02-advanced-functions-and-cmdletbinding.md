# Stage 2: Advanced Functions and CmdletBinding

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Why cmdlet-like functions matter
A function becomes a stable public API when its arguments, validation, pipeline behavior, and failure semantics are predictable. `[CmdletBinding()]` enables common parameters and advanced binding.

### A complete pipeline-aware function
```powershell
function Test-TeamCityBuildStatus {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Status
    )
    process {
        $Status -in @('FAILURE','ERROR')
    }
}
[pscustomobject]@{Status='FAILURE'} | Test-TeamCityBuildStatus
```
`ValueFromPipelineByPropertyName` binds a property named `Status`; `process` runs for each pipeline input. `[OutputType()]` documents intended output and assists tooling; it does **not** enforce the runtime type. `begin` initializes, `process` handles items, and `end` finalizes.

### Parameter validation and parameter sets
```powershell
function Get-BuildLabel {
    [CmdletBinding(DefaultParameterSetName='ById')]
    param(
        [Parameter(Mandatory,ParameterSetName='ById')][int]$Id,
        [Parameter(Mandatory,ParameterSetName='ByName')][string]$Name
    )
    if ($PSCmdlet.ParameterSetName -eq 'ById') { "Build ID: $Id" }
    else { "Build name: $Name" }
}
Get-BuildLabel -Id 123
Get-BuildLabel -Name 'Backend'
```
Parameter sets make mutually exclusive invocation shapes explicit. Common validation attributes include `[ValidateRange()]`, `[ValidateSet()]`, `[ValidatePattern()]`, and `[ValidateNotNullOrEmpty()]`. A mandatory string can still need explicit whitespace validation.

### SupportsShouldProcess and destructive actions
```powershell
function Remove-OldReport {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param([Parameter(Mandatory)][string]$LiteralPath)
    if ($PSCmdlet.ShouldProcess($LiteralPath,'Delete report')) {
        Remove-Item -LiteralPath $LiteralPath -ErrorAction Stop
    }
}
Remove-OldReport -LiteralPath './old.html' -WhatIf
```
`-WhatIf` now works because the function opted into `ShouldProcess`. Use this for commands that delete, overwrite, deploy, or mutate external systems, not read-only `Get-*` commands.

### Public naming and help
Use approved verbs (`Get-Verb`) and singular nouns: `Get-TeamCityBuild`, `New-TeamCityReport`, `Test-PipelineHealth`. Add comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, and `.OUTPUTS`. Keep parameters narrow and provide defaults only when they are genuinely safe.

### Error contract
Advanced functions support `-ErrorAction`, but a downstream command may produce non-terminating errors. Convert errors to terminating ones at a boundary when needed:
```powershell
function Read-ReportText {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$LiteralPath)
    Get-Content -LiteralPath $LiteralPath -Raw -ErrorAction Stop
}
```
Do not swallow errors merely to keep the function quiet; document whether it emits partial results.

### TeamCity application
Turn `Get-TeamCityBuildTypes` into a public advanced function that accepts a client object or explicit server/auth configuration. Keep `Invoke-TeamCityGet` private. Let callers filter, sort, and pipe returned build objects without parsing HTML. The report script itself should be a thin consumer of public commands.

### Common mistakes
Do not use `Write-Host` to return data; do not use `return` as a substitute for understanding the success stream; do not assume `[OutputType()]` validates output; and do not expose dozens of internal helper functions simply because they exist in `.psm1`.
