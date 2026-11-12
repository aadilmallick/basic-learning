# Stage 4: Object-Oriented PowerShell Foundations

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Why classes exist
A class groups state and behavior around a concept. A report row may be a plain object; a TeamCity API client is naturally stateful (server URL, credential, cache), so a class can improve cohesion.

### First class, constructor, and instance method
```powershell
class BuildResult {
    [string]$Number
    [string]$Status
    [DateTimeOffset]$FinishedAt

    BuildResult([string]$number,[string]$status,[DateTimeOffset]$finishedAt) {
        if ([string]::IsNullOrWhiteSpace($number)) { throw 'Number is required' }
        $this.Number = $number
        $this.Status = $status.ToUpperInvariant()
        $this.FinishedAt = $finishedAt
    }

    [bool] IsRed() {
        return $this.Status -in @('FAILURE','ERROR')
    }
}
$build = [BuildResult]::new('42','failure',[DateTimeOffset]::UtcNow)
$build.IsRed()
```
`$this` is the current instance; `::new` invokes the constructor. Methods in PowerShell classes have declared return types (use `[void]` for no return). Classes provide type annotations but not automatic immutability or complete invariant enforcement: public properties can still be reassigned and PowerShell may coerce values.

### Encapsulation and invariants
```powershell
class Counter {
    hidden [int]$Value = 0
    [void] Increment() { $this.Value++ }
    [int] Read() { return $this.Value }
}
```
`hidden` reduces normal visibility; it is not a security feature or true access control. For strong invariants, validate at construction and mutation boundaries. A token should never be considered secure merely because its property is hidden.

### Identity versus value
Two instances may contain identical values without being the same object. `-eq` on arbitrary reference objects is not guaranteed to implement business-value equality. For domain equality, compare stable keys such as build ID explicitly.

### Static members
```powershell
class StatusRules {
    static [bool] IsRed([string]$status) {
        return $status -in @('FAILURE','ERROR')
    }
}
[StatusRules]::IsRed('ERROR')
```
Static helpers work well for stateless rules but are harder to replace in tests than injected dependencies. Avoid turning every utility into a static class.

### Object lifecycle and data transfer
An API response is an external DTO: validate and normalize it before constructing a domain object. Do not make HTML generation methods part of `BuildResult`; that mixes presentation with domain meaning.

### Design choices
Use `PSCustomObject` for flexible, lightweight data; PowerShell classes for stable domain models or stateful clients; C# types when you need mature .NET interfaces, generics, or performance-sensitive behavior. PowerShell classes are not a requirement for clean modules.

### Connection to TeamCity report
`Get-PipelineInfo` currently constructs a large `[pscustomobject]` with many status and date fields. A `PipelineHealthResult` class could make fields discoverable and consistent, but only after defining a single constructor/factory that handles no-build, green, red, and other statuses without duplicating 20 assignments.
