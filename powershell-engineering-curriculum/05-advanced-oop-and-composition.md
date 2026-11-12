# Stage 5: Advanced OOP and Composition

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## Inheritance is not the default
Inheritance models an 'is-a' relationship; composition models a 'has-a' relationship. A report service **has a** TeamCity client and **has a** renderer. It is not a specialized TeamCity client.

### Inheritance example
```powershell
class ReportArtifact {
    [string]$Name
    ReportArtifact([string]$name) { $this.Name=$name }
    [string] Describe() { return "Artifact: $($this.Name)" }
}
class HtmlArtifact : ReportArtifact {
    HtmlArtifact([string]$name) : base($name) {}
    [string] FileExtension() { return '.html' }
}
[HtmlArtifact]::new('health').Describe()
```
The subclass inherits behavior. Use this sparingly: deep hierarchies are difficult to change and PowerShell class capabilities differ from C#.

### Composition example
```powershell
class ReportService {
    [object]$DataProvider
    [scriptblock]$Renderer
    ReportService([object]$provider,[scriptblock]$renderer) {
        $this.DataProvider=$provider
        $this.Renderer=$renderer
    }
    [string] Render([object[]]$rows) {
        return [string](& $this.Renderer $rows)
    }
}
$service = [ReportService]::new($null, { param($rows) "Rows: $($rows.Count)" })
$service.Render(@(1,2,3))
```
This demonstration injects behavior as a scriptblock. In larger systems, prefer a stable interface or explicit function contract. A renderer is replaceable without rewriting the report service.

### Polymorphism and interfaces
C# interfaces are a powerful contract mechanism, but PowerShell classes do not support declaring arbitrary `interface` types in PowerShell syntax. They can implement some existing .NET interfaces; when you need a custom compiled interface, define it in C# and load its assembly. In PowerShell-only code, you can often achieve the same practical substitution using advanced functions, scriptblocks, or objects with a documented method contract.

### Abstracting HTTP
A testable API client should depend on an HTTP operation rather than hardcoding all `Invoke-RestMethod` calls. In a lightweight design, inject a scriptblock:
```powershell
$fakeGet = { param($uri,$headers) [pscustomobject]@{buildType=@()} }
& $fakeGet 'https://ci.example.test/app/rest/buildTypes' @{}
```
In production, the real implementation calls `Invoke-RestMethod`; in tests, the fake returns known data. This is dependency inversion without requiring a complex class hierarchy.

### SOLID, translated to PowerShell
**Single responsibility:** API access does not generate HTML. **Open/closed:** add a renderer without changing the scanner. **Liskov substitution:** replacement providers must preserve return and failure contracts. **Interface segregation:** consumers need only the operations they use. **Dependency inversion:** orchestration depends on a stable provider contract, not hardcoded network calls.

### When not to use OOP
Avoid an elaborate `ReportFactoryManagerBase` hierarchy for three reports. A `New-HtmlReport` function plus a few typed models may be clearer. Optimize for change boundaries, not class count.

### TeamCity target
Separate `TeamCityClient`, `PipelineHealthAnalyzer`, and `HtmlReportRenderer` conceptually. The client owns HTTP and cache, analyzer owns status rules, renderer owns markup. The orchestration layer composes them.
