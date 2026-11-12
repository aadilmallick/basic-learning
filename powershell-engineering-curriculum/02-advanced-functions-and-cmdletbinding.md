# Stage 2 — Advanced functions: design a command people can safely compose

Stage 1 established that a command's output is a sequence of objects. This chapter develops the other half of the contract: how callers provide input, how the engine validates it, and how a command participates in the pipeline. All examples use PowerShell 7.4+; blocks marked **Offline example** need no external service. The chapter deliberately develops functions before adding classes, because functions are usually the best public interface for a PowerShell module.

## 2.1 Start with the caller's problem

A user wants to inspect a pipeline by ID, get predictable structured results, and request diagnostics with `-Verbose`. They should not need to know your internal variable names, invoke class constructors, or edit the module's source. An advanced function is a function that opts into cmdlet-style parameter binding and related facilities.

`[CmdletBinding()]` does not make code compiled, transactional, secure, or automatically testable. It connects the function to the command infrastructure: common parameters, richer binding behavior, and the `$PSCmdlet` object. The function's internal design is still your responsibility. The formal attribute options are documented in [about_Functions_CmdletBindingAttribute](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute).

Choose a verb that describes the observable operation. `Get-` retrieves, `ConvertTo-` changes representation, `Test-` answers a condition, and `New-` creates something. A function named `Get-PipelineHealth` should not silently delete old report files. A module-specific noun such as `TeamCityBuild` reduces name collisions with unrelated modules.

## 2.2 A complete advanced function

**Offline example 1 — a small but useful public contract.**

```powershell
function Get-TeamCityBuildLabel {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BuildTypeId,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int]$BuildNumber,

        [switch]$IncludeStatus
    )
    Write-Verbose "Creating label for $BuildTypeId"
    $label = '{0} #{1}' -f $BuildTypeId, $BuildNumber
    if ($IncludeStatus) { $label += ' [status unavailable]' }
    $label
}
Get-TeamCityBuildLabel -BuildTypeId Backend_Build -BuildNumber 12 -Verbose
```

The function emits `Backend_Build #12`. `[Parameter(Mandatory)]` asks the binder to require input; in interactive use, omitted mandatory arguments can prompt. In unattended jobs, supply all required values and use a noninteractive process so a forgotten argument cannot hang waiting for a person.

`[ValidateRange]` checks the converted integer. `[ValidateNotNullOrEmpty]` rejects null and empty text but does not reject whitespace-only strings. For identifiers, a separate whitespace or character policy may be necessary. Validation attributes are useful only when their exact rule matches the input contract.

`[OutputType]` is metadata for help and tooling. It does not coerce or enforce the actual output. A stray diagnostic string still appears in the success stream. `PositionalBinding = $false` makes this function's parameters named unless positions are explicitly declared; explicit calls become easier to read during reviews.

A switch is a presence-oriented parameter. `-IncludeStatus` means true, while `-IncludeStatus:$false` explicitly binds false. Do not test only whether a switch name appears in `$PSBoundParameters` when your intent is to test whether the option is enabled.

## 2.3 Defaults, binding, and validation belong at different layers

The binder converts supplied arguments to declared types and applies validation. The function body then performs operations whose validity may depend on several inputs or external state. Keep inexpensive local validation near the parameter; keep network checks and cross-field rules in the body or a dedicated configuration constructor.

**Offline example 2 — reject an unusable server configuration.**

```powershell
function New-TeamCityEndpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [uri]$Server,
        [ValidateRange(1, 1000)]
        [int]$PageSize = 100
    )
    if (-not $Server.IsAbsoluteUri -or $Server.Scheme -ne 'https') {
        throw 'Server must be an absolute HTTPS URI.'
    }
    if ($Server.UserInfo -or $Server.Query -or $Server.Fragment) {
        throw 'Server must not contain credentials, query, or fragment.'
    }
    [pscustomobject]@{
        Server = $Server
        PageSize = $PageSize
    }
}
New-TeamCityEndpoint -Server 'https://ci.example.com/teamcity/'
```

The `[uri]` type gives you structured URI properties. It does not guarantee an absolute URI, HTTPS, or an acceptable server path. That is why the explicit checks remain necessary. Separating type conversion from domain validation prevents the false assumption that a typed parameter is already trustworthy.

Defaults are part of the interface. A default page size affects performance; a default server URL affects which system receives credentials. For reusable learning code, require the server or obtain it from deliberate application configuration. Avoid hardcoding a company endpoint into a general-purpose client.

Do not rely on parameter validation attributes as a universal validator for internal defaults. Validate important invariants in the object or operation that consumes them. Similarly, a `[ValidateScript]` block that reads a file or makes a request can introduce surprising side effects during binding. Prefer straightforward body validation when the check needs context or a useful custom error.

## 2.4 Parameter sets represent alternative ways to ask one question

One command might retrieve a build configuration by ID or search by name. Requiring both parameters would be awkward; accepting either without defining exclusivity makes ambiguous calls possible. Parameter sets encode legitimate invocation shapes.

**Offline example 3 — one operation, two selectors.**

```powershell
function Find-TeamCityConfiguration {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$Id,
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name,
        [switch]$IncludeArchived
    )
    [pscustomobject]@{
        Selector = $PSCmdlet.ParameterSetName
        Value = if ($PSCmdlet.ParameterSetName -eq 'ById') { $Id } else { $Name }
        IncludeArchived = $IncludeArchived.IsPresent
    }
}
Find-TeamCityConfiguration -Id 'Backend_Build'
Find-TeamCityConfiguration -Name 'Build backend' -IncludeArchived
```

`IncludeArchived` belongs to every set because no set is specified for it. Passing both `-Id` and `-Name` cannot resolve to one of these sets and fails during binding. The default set helps resolve otherwise ambiguous calls; it does not supply missing mandatory values.

Use sets when alternatives describe one coherent operation. If the sets require unrelated parameters, emit different object types, and perform unrelated effects, separate commands are often clearer. Parameter sets should express meaningful choices, not conceal several applications behind one name.

Avoid growing a combinatorial matrix of sets. Three independent binary options can quickly become difficult to document. Configuration objects and separate workflow commands can express more complex behavior without burdening the binder with every possible business state.

## 2.5 Pipeline binding by value and by property name

Pipeline input is not the same as passing an array argument. With a suitable `process` block, each upstream object is bound and processed individually. `ValueFromPipeline` binds the incoming object itself. `ValueFromPipelineByPropertyName` uses a matching property, including declared aliases.

**Offline example 4 — normalize an external name into your command vocabulary.**

```powershell
function Get-TeamCityConfigurationKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [ValidateNotNullOrEmpty()]
        [string]$BuildTypeId
    )
    process {
        [pscustomobject]@{ BuildTypeId = $BuildTypeId }
    }
}
@(
    [pscustomobject]@{ id = 'Backend_Build'; name = 'Backend' }
    [pscustomobject]@{ id = 'Frontend_Build'; name = 'Frontend' }
) | Get-TeamCityConfigurationKey
```

The two output objects have keys `Backend_Build` and `Frontend_Build`. The alias maps the external DTO's `id` to a clearer parameter name. This is a small adapter: external vocabulary ends at a boundary, while the command speaks the application's vocabulary.

Binding has an ordered search involving exact matches and conversions for by-value and property-name input. Avoid interfaces that depend on readers remembering every precedence rule. A generic `[object]` by-value parameter accepts almost anything and can dominate the intended design. Choose one obvious path where possible and test the shapes you intend to support. Microsoft's [advanced parameter reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters) documents the binding facilities.

For a function that accepts one object per record, use a scalar parameter and `process`. For a function that calculates statistics for one explicitly supplied batch, use an array parameter. A pipeline aggregator can combine both patterns, but document whether it emits one result per item or one result for the whole invocation.

## 2.6 Begin, process, end, and clean

**Offline example 5 — count without buffering the whole input.**

```powershell
function Measure-TeamCityHealth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]$InputObject
    )
    begin { $total = 0; $red = 0 }
    process {
        $total++
        if ($InputObject.Status -in @('FAILURE', 'ERROR')) { $red++ }
    }
    end {
        [pscustomobject]@{
            Total = $total
            Red = $red
            RedPercent = if ($total) { 100.0 * $red / $total } else { 0.0 }
        }
    }
}
@(
    [pscustomobject]@{ Status = 'SUCCESS' }
    [pscustomobject]@{ Status = 'FAILURE' }
) | Measure-TeamCityHealth
```

`begin` initializes once, `process` handles each record, and `end` emits one aggregate. Two input objects produce one result with total 2 and red count 1. The function stores only counters, so its additional memory use is independent of the number of builds.

An `end` block is a normal completion phase, not a universal cleanup guarantee. PowerShell 7.3 introduced `clean` for resource cleanup across completion and interruption scenarios. Success output from `clean` is discarded. The distinction is described in [advanced function methods](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods). Stage 3 develops resource ownership with `try/finally`; that remains useful inside a single operation.

Never place all per-record work outside `process` and assume declaring `ValueFromPipeline` is sufficient. Also avoid using `$input` and a bound pipeline parameter together without a specific reason; two competing input mechanisms make consumption difficult to reason about.

## 2.7 ShouldProcess: preview the effect at the effect boundary

PowerShell's `-WhatIf` is useful for a report writer because it tells callers which file would be written. It requires both declaring support and calling `$PSCmdlet.ShouldProcess()` before the actual effect. Merely adding the attribute does not protect a write.

**Offline example 6 — preview a write without creating a file.**

```powershell
function Export-TeamCityText {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text
    )
    $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $LiteralPath
    )
    if ($PSCmdlet.ShouldProcess($resolved, 'Write TeamCity text artifact')) {
        [IO.File]::WriteAllText($resolved, $Text, [Text.UTF8Encoding]::new($false))
        Get-Item -LiteralPath $resolved
    }
}
Export-TeamCityText -LiteralPath './preview-only.html' -Text '<p>Example</p>' -WhatIf
```

This invocation reports the planned action and creates no file. The writer emits a `FileInfo` only after a real successful write. That output contract should be documented; a preview does not fabricate an artifact that does not exist.

The parent directory must already exist in this small writer. Stage 12's application owns directory creation. This division keeps the example focused and makes the precondition explicit. `LiteralPath` also communicates that wildcard expansion is inappropriate for an exact destination.

A read-only API lookup normally does not need `ShouldProcess`. Preview support for a multi-step command requires a precise definition: does it perform discovery requests but skip file writes, or skip all work? Name the effects and guard them individually. Do not depend on implicit propagation to a .NET write, because .NET methods do not know PowerShell's common parameters.

## 2.8 Bound parameters, splatting, and wrapper commands

`$PSBoundParameters` contains parameters explicitly bound for the current invocation, including common parameters. It does not contain every default-valued parameter. That distinction lets a wrapper tell “caller omitted this option” from “caller explicitly supplied the default.” It also means blindly forwarding the entire dictionary can send unsupported options to another command.

**Offline example 7 — forward a deliberate subset.**

```powershell
function New-TeamCityQueryDescription {
    [CmdletBinding()]
    param([string]$BuildTypeId = 'Backend_Build', [int]$Count = 10)
    $query = @{ BuildTypeId = $BuildTypeId; Count = $Count }
    [pscustomobject]@{
        Id = $query.BuildTypeId
        Count = $query.Count
        CountWasExplicit = $PSBoundParameters.ContainsKey('Count')
    }
}
New-TeamCityQueryDescription
New-TeamCityQueryDescription -Count 10
```

Both calls request the same count, but only the second records explicit intent. For HTTP calls, create a new splatting hashtable containing supported request parameters. For public wrappers, selectively copy compatible values and decide how to handle `Verbose`, `ErrorAction`, and preview behavior.

Avoid secrets in verbose messages. Diagnostics should identify the operation, configuration ID, and safe status information; they should not print authorization headers or the entire request hashtable. Once a log contains a token, hiding the property on a class does not recover confidentiality.

## 2.9 Help and stable command contracts

Comment-based help belongs next to the function and should describe semantics, not repeat parameter names. For `MaxBuildsToScan`, explain that it bounds evidence and can make the failure start uncertain. For `ExcludeProjectName`, explain wildcard matching and whether exclusions apply to immediate projects, ancestors, or both.

A useful help example includes setup, invocation, and output meaning. State whether the command contacts a server, writes a file, returns data, or emits a partial result on failure. `Get-Help CommandName -Full` then becomes a practical interface manual rather than a list of types.

Changing a property name can break callers just as surely as changing a parameter. Treat output shape as part of the public contract. Prefer adding a new optional property over silently repurposing an existing one. Error identifiers, ordering guarantees, and null meanings may also matter to downstream scripts.

## 2.10 Design help around decisions, including empty input

The most useful parameter help describes the decision a caller must make. A history limit is an evidence bound. An output path is a filesystem effect. A switch allowing partial scans changes the reliability contract. Merely writing “specifies the limit” or “specifies the path” leaves the important meaning unstated.

For collection parameters, explicitly decide whether empty input is valid. PowerShell's binder treats mandatory arguments, null, empty strings, and empty collections differently. Attributes such as `AllowEmptyCollection`, `AllowEmptyString`, and `AllowNull` document exceptions to ordinary binding checks. They do not make every element valid. A permitted empty array can represent a valid zero-result query, while an array containing a null element may still violate the command's contract.

**Offline example 8 — accept an explicit empty batch without fabricating a row.**

```powershell
function Measure-ConfigurationBatch {
    <#
    .SYNOPSIS
    Counts configurations in one explicitly supplied batch.
    .DESCRIPTION
    An empty batch is valid and returns a count of zero. Null elements are rejected.
    This function performs no discovery and makes no network requests.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Configuration
    )
    foreach ($item in $Configuration) {
        if ($null -eq $item) { throw 'A configuration element must not be null.' }
    }
    [pscustomobject]@{ Count = $Configuration.Count }
}
Measure-ConfigurationBatch -Configuration @()
```

The command returns one summary with count zero. It does not need a pipeline parameter because its operation is defined over one explicit batch. That is an intentional contract rather than a missing feature. If a pipeline version is added later, decide how multiple batches compose: should they produce one summary each, or one aggregate for the entire invocation?

Parameter aliases can ease migration, but use them for equivalent names rather than different meanings. An alias from legacy `MaxBuildsToScan` to `Limit` is defensible if semantics match. An alias that changes “all branches” into “default branch” is not. Compatibility includes meaning, not just spelling.

## 2.11 The TeamCity connection

The uploaded script declares advanced binding at the script entry point, but most helper functions are ordinary functions. That is acceptable for small private helpers. Public module commands deserve explicit binding, help, input validation, and output contracts because other scripts will depend on them independently.

For the eventual design, `Get-TeamCityBuildType` retrieves configurations, `Get-TeamCityBuildHistory` retrieves observations, `Get-PipelineHealth` interprets observations, `ConvertTo-PipelineHtml` renders content, and `Export-HtmlArtifact` writes it. Each name makes one responsibility visible. The entry script composes them and chooses application policy.

These boundaries make OOP more useful: a client can own connection state while advanced functions present an idiomatic command surface. A class method is not a substitute for pipeline binding, help, `ShouldProcess`, or common parameters. Good PowerShell design lets the language's command model and its object model cooperate.

## 2.12 Walk through parameter binding as a sequence of decisions

Suppose a caller runs a history command with a configuration ID and a textual count of `'25'`. PowerShell first identifies the command and its parameter metadata. The binder associates named arguments with parameters, determines a usable parameter set, converts values where needed, and applies the declared validation rules. Only after successful binding does the command's operational body run.

This explains why some errors happen before your first `Write-Verbose` line. A conversion failure or unresolved parameter set is not a failure inside the HTTP helper; the request never began. A catch inside the function body cannot repair an invocation that could not bind in the first place. The caller or outer application boundary owns presentation of that failure.

Now consider the same ID arriving as a property on a pipeline object. The binder must apply the function's pipeline rules to each incoming record. The `process` block is where the operation uses the bound value. Initialization in `begin` should not assume a per-record pipeline value is already available. A function that constructs the first request in `begin` from a pipeline-bound ID is therefore mixing invocation-level setup with record-level data.

Default values introduce another distinction. A parameter may have a value in the body even when the caller never bound it. `$PSBoundParameters` records explicit binding, which is useful for wrappers but incomplete as a complete options object. If you need the effective configuration, construct it from parameter variables after binding and validate its cross-field rules.

Do not use parameter sets to encode every branch of the implementation. They model ways of invoking the command. A retry limit, branch selector, and output format may be independent options rather than separate sets. By contrast, selecting a resource by numeric build ID versus by configuration and build number may represent genuinely alternative selectors with different required inputs.

When binding behavior is surprising, reduce the input to one object with the intended property names. Inspect `Get-Command YourCommand -Syntax` and its parameter metadata. Then add complexity gradually. A minimal binding experiment is often easier to understand than a trace from a large pipeline containing several object types.

## 2.13 Design a command family, not one overloaded entry point

A useful module lets callers choose their level of composition. Someone building a custom report may want raw normalized observations. Someone running a scheduled job may want one application command that performs the entire workflow. These needs can coexist when the command family has coherent layers.

For example, the API module can expose a factory and retrieval commands. The health module exposes interpretation and summary commands. The artifact module exposes conversion and export. The entry script composes them for the common report. This is more flexible than a single command with switches for “only query,” “only analyze,” “only render,” and “skip everything except writing.”

Keep nouns consistent across the family. If `BuildTypeId`, `ConfigurationId`, and `PipelineId` all mean the same external key in different places, explain the boundary vocabulary or choose one term for public API commands. Internally, a report row may reasonably call it `PipelineId` because that is the reader's concept, but adapters should make the translation visible.

Return types should also fit together. A retrieval command that emits one observation at a time composes naturally with filters and explicit collection. An analyzer that emits one result per configuration can feed a report collector. A writer that returns `FileInfo` lets the application report actual artifacts. Mixing status strings, progress messages, and row objects breaks this composability even if every function has excellent parameter validation.

Help should state ordering guarantees and scope. “Returns builds” is insufficient for a streak algorithm; “returns matching observations in the server's newest-first sequence” gives the caller a precondition they can reason about. Likewise, “red percentage” needs a denominator and “project exclusion” needs an ancestry scope.

Compatibility wrappers are a useful final step when migrating existing callers. A wrapper can accept old parameter names, construct the new effective options, and delegate to the new commands. Keep it thin and test its translation. If the wrapper contains a second copy of the analyzer, you now have two policies to maintain.

Finally, be selective about convenience aliases and positional parameters. Interactive brevity is valuable, but saved automation benefits from readable named arguments. A stable command family should make the common path concise while keeping its meaning obvious when another engineer reads it months later.

Remember that binding success is only the start of execution. A valid HTTPS URI can point to an unavailable server, and a valid identifier can name a resource the token cannot read. Keep local argument validation distinct from external-operation failure so callers receive the right explanation and recovery advice.
