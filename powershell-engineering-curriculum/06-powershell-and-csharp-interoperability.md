# Stage 6: PowerShell and CSharp Interoperability

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## PowerShell already runs on .NET
Before writing C#, exploit the .NET standard library directly. `StringBuilder`, `DateTimeOffset`, `Uri`, `WebUtility`, and generic collections already solve many common scripting problems.

### Calling .NET safely
```powershell
$builder = [System.Text.StringBuilder]::new()
[void]$builder.AppendLine('<h1>Pipeline health</h1>')
[void]$builder.AppendLine('<p>Generated</p>')
$builder.ToString()
```
`AppendLine` returns the builder; `[void]` discards that return value so it does not pollute the success stream. The uploaded script uses exactly this technique.

### Generic collections
```powershell
$items = [System.Collections.Generic.List[string]]::new()
$items.Add('backend')
$items.Add('frontend')
$items.Count
```
Generic types specify element types. A `List[T]` avoids repeated array copying when appending many items. A `Dictionary[string,object]` can be useful for caches, although a PowerShell hashtable is usually sufficient.

### DateTimeOffset versus DateTime
TeamCity returns timestamps with offsets. Parse them as `DateTimeOffset` to preserve the instant and offset before choosing a display timezone:
```powershell
$timestamp = [DateTimeOffset]::Parse('2026-10-21T15:30:00-04:00')
$timestamp.UtcDateTime
$timestamp.ToString('yyyy-MM-dd HH:mm:ss zzz')
```
`LocalDateTime` depends on the machine's timezone; a TeamCity agent in UTC and a workstation in Eastern Time can render different clock times. Make report timezone an explicit choice.

### Compiling a small C# helper
```powershell
Add-Type -TypeDefinition @'
public static class PipelineRules {
    public static bool IsRed(string status) {
        return status == "FAILURE" || status == "ERROR";
    }
}
'@
[PipelineRules]::IsRed('FAILURE')
```
`Add-Type` compiles a type into the current session. Repeatedly defining the same type name in a session can fail; use unique names or load compiled assemblies for production. The helper demonstrates interop, but the equivalent PowerShell function is simpler for this rule.

### When C# adds value
Consider C# for reusable libraries consumed by multiple .NET languages, custom interfaces, strongly typed models shared across assemblies, complex parsing, or measured performance bottlenecks. Avoid C# merely to make ordinary PowerShell scripts look object-oriented.

### Assembly and compatibility concerns
Windows PowerShell 5.1 uses .NET Framework; PowerShell 7 uses modern .NET. A compiled DLL targeting one environment may not load in the other. Check ` $PSVersionTable.PSVersion ` and ` $PSVersionTable.PSEdition ` and choose compatible targets. Test on the actual TeamCity agent OS and PowerShell version.

### Secure boundaries
Never embed credentials in source, DLL constants, or reports. Environment variables are convenient for CI but can leak through process or logging surfaces; use the CI platform's protected secret facilities and restrict output.

### TeamCity connection
The source already uses .NET APIs effectively. A good refactor keeps those APIs where useful, introduces typed models only where they improve correctness, and avoids a needless C# rewrite.
