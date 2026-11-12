# Stage 5 — Composition, inheritance, polymorphism, and .NET contracts

Stage 4 introduced one object at a time. Real applications need objects and functions to collaborate. This chapter explains how to choose those relationships without building an elaborate hierarchy that makes a reporting script harder to change. Use PowerShell 7.4+. Each **Offline example** is self-contained; start a fresh process when revising a class definition.

## 5.1 Begin with a change you expect to make

Suppose the report currently reads TeamCity but should also support saved JSON fixtures. If the analyzer makes HTTP calls itself, offline testing requires intercepting networking. If the analyzer receives build observations, it does not care where they came from. That is dependency separation before any special syntax is introduced.

Three ideas are often confused. Composition means one component uses or owns another. Inheritance means one type derives from another and inherits its contract or implementation. Polymorphism means a caller can use different implementations through a common operation. Polymorphism can be achieved with a .NET interface, a base class, a script block, or a consistent function contract; it does not require a deep class hierarchy.

Use inheritance when substitutability is real: every derived object must behave acceptably wherever the base is expected. Use composition when the relationship is “uses” or “has,” especially when independent features vary. A TeamCity client uses a transport; it is not a kind of transport. A report uses a health analyzer; it is not a kind of pipeline.

## 5.2 Composition with an explicit collaborator

**Offline example 1 — replace the build source without changing the consumer.**

```powershell
class HealthReader {
    hidden [scriptblock]$loadBuilds

    HealthReader([scriptblock]$loadBuilds) {
        if ($null -eq $loadBuilds) { throw 'A build source is required.' }
        $this.loadBuilds = $loadBuilds
    }

    [string] GetLatestStatus([string]$buildTypeId) {
        $builds = @(& $this.loadBuilds $buildTypeId)
        if ($builds.Count -eq 0) { return 'NO_BUILDS' }
        return [string]$builds[0].Status
    }
}
$fixtureSource = {
    param($buildTypeId)
    [pscustomobject]@{ Id = '101'; Status = 'FAILURE'; BuildTypeId = $buildTypeId }
}
$reader = [HealthReader]::new($fixtureSource)
$reader.GetLatestStatus('Backend_Build')
```

The reader owns a reference to a collaborator and invokes it through `&`. The script block contract is simple: accept an ID and emit builds newest first. The consumer knows the contract but not the storage mechanism. This is lightweight dependency injection: provide the dependency from outside rather than constructing it inside the operation.

A script block is flexible and easy to fake, but PowerShell does not statically verify its output shape. Document the contract and validate at the boundary. A typed .NET interface offers stronger signatures, while a function parameter can be entirely adequate for a small application. Choose the weakest mechanism that still makes the intended rules clear and testable.

This example is not a thread-safe callback framework. Script blocks execute in PowerShell session and runspace contexts. If C# invokes one on an arbitrary thread, it may have no usable runspace. Concurrency requires an explicit execution model, covered later as a design tradeoff rather than assumed safe behavior.

## 5.3 Inheritance for a genuine specialization

**Offline example 2 — share one stable result contract.**

```powershell
class ArtifactDescription {
    [string]$Name
    ArtifactDescription([string]$name) { $this.Name = $name }
    [string] GetMediaType() { return 'application/octet-stream' }
}
class HtmlArtifactDescription : ArtifactDescription {
    HtmlArtifactDescription([string]$name) : base($name) { }
    [string] GetMediaType() { return 'text/html' }
}
$artifacts = @(
    [ArtifactDescription]::new('raw-data')
    [HtmlArtifactDescription]::new('health-report')
)
foreach ($artifact in $artifacts) {
    '{0}: {1}' -f $artifact.Name, $artifact.GetMediaType()
}
```

The colon names the base class, and `: base($name)` invokes the base constructor. Both objects support `Name` and `GetMediaType()`. The derived method supplies behavior appropriate for HTML. The consumer calls the same method without branching on concrete types.

This is intentionally a narrow hierarchy. Adding subclasses for “red HTML report,” “green HTML report,” “summary HTML report,” and every theme would confuse data variation with type variation. A template name or options object is often a better representation. Inheritance is a commitment to a shared behavioral contract, not merely a way to reuse ten lines.

PowerShell classes inherit from one base class and can implement .NET interfaces. They do not provide all C# type-system features or access modifiers. Check the [inheritance reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes_inheritance) before copying C# patterns directly.

## 5.4 Substitutability is about behavior, not just signatures

Suppose a base source promises “returns zero or more observations, newest first, without modifying them.” A derived source that returns HTML strings technically fits an `[object[]]` return type but violates the behavioral contract. A derived source that refuses IDs accepted by the base may also break callers.

This is the practical meaning of the Liskov substitution principle: code written against the general contract should remain correct for the specialization. You do not need formal proof machinery to apply it. Write down accepted inputs, output shape, ordering, effects, and error behavior; then ask whether every implementation honors them.

Throwing “not implemented” from half the methods of a derived class is a warning sign. The base probably promises too much. Smaller interfaces or composition let each component support only meaningful operations. For example, a read-only fixture source need not inherit a client API that can queue builds and modify projects.

## 5.5 Implementing a .NET interface

An interface names capabilities without supplying ordinary instance state. PowerShell can implement existing .NET interfaces, although it cannot declare an interface using a PowerShell `interface` keyword. A custom interface can be defined in C# and loaded with an assembly; stage 6 explains that boundary.

**Offline example 3 — implement a small standard contract.**

```powershell
class OwnedReportBuffer : System.IDisposable {
    hidden [IO.MemoryStream]$stream
    [bool]$IsDisposed

    OwnedReportBuffer() {
        $this.stream = [IO.MemoryStream]::new()
        $this.IsDisposed = $false
    }

    [void] WriteText([string]$text) {
        if ($this.IsDisposed) { throw [ObjectDisposedException]::new('OwnedReportBuffer') }
        $bytes = [Text.Encoding]::UTF8.GetBytes($text)
        $this.stream.Write($bytes, 0, $bytes.Length)
    }

    [void] Dispose() {
        if (-not $this.IsDisposed) {
            $this.stream.Dispose()
            $this.IsDisposed = $true
        }
    }
}
$buffer = [OwnedReportBuffer]::new()
try { $buffer.WriteText('<p>Health</p>') }
finally { $buffer.Dispose() }
$buffer.IsDisposed
```

The interface requires a `Dispose()` method returning void. The implementation makes repeated disposal harmless. The object guards use after disposal and owns the underlying stream. Merely implementing `IDisposable` does not cause PowerShell to dispose your object automatically; the caller still needs a lifetime boundary.

The public `IsDisposed` property is mutable here, so it is diagnostic state rather than a robust security guarantee. This small class teaches mechanics. A production reusable resource wrapper may be better implemented in C# with private fields. Recognizing the limit is part of advanced OOP, not a failure to use enough attributes.

## 5.6 Prefer narrow data contracts to broad object graphs

A health analyzer needs build status and time, not a client's token, HTTP headers, project cache, and output destination. Passing an entire client to every function gives each function more authority and knowledge than it needs. Pass the smallest useful view.

**Offline example 4 — a pure function with an explicit ordering contract.**

```powershell
function Get-LeadingRedCount {
    [CmdletBinding()]
    param([object[]]$NewestFirstBuilds = @())
    $count = 0
    foreach ($build in $NewestFirstBuilds) {
        if ([string]$build.Status -notin @('FAILURE', 'ERROR')) { break }
        $count++
    }
    $count
}
$history = @(
    [pscustomobject]@{ Status = 'FAILURE' }
    [pscustomobject]@{ Status = 'ERROR' }
    [pscustomobject]@{ Status = 'SUCCESS' }
    [pscustomobject]@{ Status = 'FAILURE' }
)
Get-LeadingRedCount -NewestFirstBuilds $history
```

The answer is two because the older failure after success belongs to a different streak. The parameter name advertises ordering. The function has no client dependency, no clock dependency, and no file effect. This makes the important business rule easy to test without mocking class internals.

Purity is not a requirement for every component. HTTP and file writing are inherently effectful. The architectural goal is to place those effects at narrow boundaries so the rules between them can remain simple. Classes can own the boundaries while ordinary functions express deterministic transformations.

## 5.7 Static members and shared state

A static member belongs to the type rather than one instance. A constant-like helper can be useful; a mutable static cache can unexpectedly couple unrelated clients, tests, and scans. If the cache key is only a project ID, data from two servers can collide.

**Offline example 5 — see the difference between shared and instance state.**

```powershell
class ScanIdentity {
    static [int]$Created = 0
    [string]$Name
    ScanIdentity([string]$name) {
        $this.Name = $name
        [ScanIdentity]::Created++
    }
}
$first = [ScanIdentity]::new('morning')
$second = [ScanIdentity]::new('evening')
$first.Name
$second.Name
[ScanIdentity]::Created
```

The names differ, while the shared count is two. This is useful for learning but is not a concurrency-safe unique ID generator. Incrementing shared mutable state is not automatically atomic, and separate processes have separate memory. Use a GUID or another explicit identity mechanism for scans.

For the TeamCity client, per-instance caches naturally separate servers and credentials. A cache's lifetime can match one report run or one deliberately reusable session. If you need cross-run caching, define invalidation, server identity, freshness, persistence, and access policy explicitly. Static state does not answer those questions.

## 5.8 Type constraints, enums, and unknown external values

An enum gives a named finite set of values. It is useful for internal states such as `Green`, `Red`, and `Other`; a raw external status may evolve beyond the set you know. Keep the raw value alongside the interpretation so an unfamiliar server value remains visible.

**Offline example 6 — retain information while classifying.**

```powershell
enum PipelineHealthKind { Green; Red; Other }
function ConvertTo-HealthKind {
    param([string]$Status)
    switch ($Status.ToUpperInvariant()) {
        'SUCCESS' { [PipelineHealthKind]::Green; break }
        'FAILURE' { [PipelineHealthKind]::Red; break }
        'ERROR' { [PipelineHealthKind]::Red; break }
        default { [PipelineHealthKind]::Other }
    }
}
foreach ($status in @('SUCCESS', 'FAILURE', 'UNKNOWN')) {
    [pscustomobject]@{ RawStatus = $status; Health = ConvertTo-HealthKind $status }
}
```

This mapping preserves the source vocabulary and exposes the application's policy. `ERROR` is retained because the uploaded script treats it as red; that does not imply every TeamCity version uses it as a normal REST build-status value. Stage 9 distinguishes server documentation from local compatibility policy.

Enums also require deliberate serialization. JSON may represent an enum numerically unless you choose a string representation. At durable boundaries, an explicit projection such as `[string]$result.Health` is easy for other languages to understand. A strong in-process type does not automatically create a stable wire format.

## 5.9 Avoid inheritance as a configuration language

If one customer excludes experimental builds and another excludes archived projects, those are policies or options, not necessarily subclasses. If one report uses a dark theme and another a light theme, data-driven CSS is usually simpler than a renderer hierarchy. Inheritance multiplies type relationships; options multiply data values. Choose the mechanism that matches what actually varies.

Composition introduces its own costs. Too many tiny interfaces and factories can make a small script difficult to navigate. A three-function module may need only explicit parameters and one injected script block. Add abstraction when you can name a concrete benefit: offline testing, a second implementation, stable cross-language contracts, or independent release boundaries.

Avoid service locators that let any component fetch any dependency by name. They hide the dependency graph again. Constructor or function parameters make required collaborators visible. A composition root—the entry script that builds the components—can wire them together in one understandable place.

## 5.10 Concurrency, serialization, and PowerShell-specific limits

PowerShell class methods, script blocks, and module state should not be assumed safe to share across runspaces. A concurrent dictionary only protects its own operations; it does not make an entire client, its callbacks, or multi-step cache logic thread-safe. First implement a correct sequential scan, measure it, and then choose a bounded parallel model.

Jobs and remoting often return deserialized representations with properties but without the original live methods. A class-based in-process contract should therefore have a deliberate data projection at process boundaries. For reporting, plain data is usually more portable than expecting remote callers to invoke custom methods.

These constraints do not make PowerShell OOP unsuitable. They identify where the language is strongest: orchestrating .NET, defining useful models, owning session state, and exposing commands. Use C# when stronger type contracts, private state, or threaded algorithms justify the extra packaging work.

## 5.11 Callback lifetime and closures deserve explicit ownership

A script block can capture variables from its creation context with `GetNewClosure()`. That is useful for a fixture source that needs access to one dataset or a transport that records requests in one list. The closure keeps references to captured objects; it does not deep-copy their contents. Mutating a captured hashtable can therefore affect later calls.

**Offline example 7 — build two independent strategy instances.**

```powershell
function New-FixtureStatusReader {
    param([string]$Status)
    $state = @{ Status = $Status; Calls = 0 }
    $read = {
        param($id)
        $state.Calls++
        [pscustomobject]@{ Id = $id; Status = $state.Status; Call = $state.Calls }
    }.GetNewClosure()
    [pscustomobject]@{ Read = $read; State = $state }
}
$redSource = New-FixtureStatusReader -Status FAILURE
$greenSource = New-FixtureStatusReader -Status SUCCESS
& $redSource.Read 'A'
& $redSource.Read 'B'
& $greenSource.Read 'C'
```

The red source reports calls one and two; the green source reports call one. Each factory invocation creates separate state. The object makes ownership visible: the reader and its state belong together. This is a small composition technique without a new class hierarchy.

Captured state can also accidentally retain a large fixture, token, or open resource longer than expected. Keep callbacks narrow and give them a deliberate lifetime. Do not store per-request closures in static state unless that retention is intentional.

When comparing a callback with an interface, consider the consumer. A PowerShell-only test may prefer a script block for concise setup. A reusable .NET library may prefer an interface for compile-time signatures and tooling. A module public command may prefer plain data so callers need neither mechanism. The stable behavior contract matters more than the syntax used to express it.

Avoid “abstract” PowerShell base classes implemented only as methods that throw unless overridden when a function parameter would communicate the same requirement more clearly. Such conventions can be useful, but they are not compiler-enforced abstract contracts. Name the limitation honestly and choose a C# interface if enforcement is important.

## 5.12 Connecting the choices to the final architecture

The eventual `TeamCityAPI` component owns retrieval mechanics and per-client cache state. `PipelineHealth` accepts observations and returns evidence-based results. `HTMLArtifact` renders those results and provides a separate writer. The entry script composes them; none needs to inherit from another.

This architecture uses polymorphism at the build-source boundary: a live HTTP adapter and an offline fixture source can satisfy the same practical contract. It uses a small class where state ownership helps. It uses functions for transformations and commands. The design stays recognizably PowerShell while gaining the clarity often associated with object-oriented applications.

The next stage explains how to cross into C# deliberately, including assembly loading and collection behavior. The goal is not to replace PowerShell with C# inside a large string. It is to put each responsibility where its rules are clearest.

## 5.13 Compare three ways to make the source replaceable

The simplest source boundary is plain data: retrieve observations first, then pass them to the analyzer. This is ideal when the analyzer needs one bounded history and has no reason to control retrieval. The caller owns networking, and the analyzer is completely independent of it. For the TeamCity report, this is the preferred domain boundary.

A callback is useful when a workflow must request several histories while controlling iteration. The callback receives a configuration ID and returns observations. A fixture callback can use a dictionary; a live callback can delegate to a client. This preserves replaceability without defining another type, but output shape and error semantics rely on documentation and tests.

An interface is useful when independently maintained components need an enforceable signature. A C# `IBuildHistorySource` could return a typed sequence and accept a cancellation mechanism. PowerShell can consume that interface, and another .NET application can implement it. The cost is an assembly contract, compatible target frameworks, and a deliberate loading strategy.

These mechanisms can coexist. A client may implement a typed source interface, an entry script may wrap it in a callback for orchestration, and the analyzer may still accept only data. Do not propagate the most powerful abstraction everywhere merely because it exists. Give each consumer the narrowest dependency that supports its responsibility.

Tests should reflect the chosen boundary. A pure analyzer needs fixtures, not a fake client hierarchy. A workflow callback test checks which IDs were requested and how failures were recorded. An interface implementation test checks signature behavior, ordering, and normalization. Testing through the smallest meaningful boundary makes failures easier to locate.

## 5.14 Identify inheritance traps in a reporting application

One common trap is inheriting from a general `Report` class that requires methods for querying, analysis, rendering, and writing. An HTML report then inherits network behavior it may not need, while a fixture report must override unrelated methods. The base class has combined several axes of variation into one contract.

Another trap is subclassing the client for every exclusion policy. A “production-only client” and “experimental-excluding client” mix data retrieval with organizational selection. Exclusions usually belong to orchestration or a selection policy, because the same client may serve several reports with different scopes during one session.

A third trap is type-checking every derived object. If the consumer repeatedly asks whether an artifact is HTML, CSV, or JSON and then branches on its concrete type, the hierarchy may not be providing useful polymorphism. Either expose the operation the caller actually needs or represent the variation as ordinary data.

Inheritance can still be appropriate. A small family of exception types can let callers catch a meaningful category. A stable artifact abstraction can define a truly shared contract. The point is to require a substitutable behavior relationship rather than using inheritance as a shortcut for access to helper methods.

Composition has a corresponding failure mode: too many tiny collaborators with no stable meaning. A `StatusUppercaser`, `StatusComparer`, and `RedBooleanFactory` would make a three-line policy harder to read. Group behavior around coherent concepts and likely changes, not around every individual expression.

## 5.15 Treat lifecycle as part of the collaboration contract

When one component receives another, decide who owns it. If a workflow receives a client created by the caller, it should normally use it without disposing or resetting it unexpectedly. If the workflow creates a short-lived resource internally, it normally owns cleanup. The contract should not depend on guessing from implementation details.

Stateful collaborators also need a reuse policy. Can a client be used for two sequential scans? Does its cache remain valid? Can two scans use it concurrently? A small teaching client may support sequential reuse while making no concurrency guarantee. Saying that explicitly is better than assuming that a dictionary or class declaration supplies synchronization.

Consider failure during collaboration. A source may fail for one configuration while remaining usable for others. A renderer may fail on a malformed row without corrupting the source. Keeping components independent lets the application decide whether to continue, retry, or stop. A large inheritance tree with shared mutable fields can make one failure affect unrelated operations.

The same lifetime reasoning applies to fixtures. A callback with a captured mutable dictionary is a stateful dependency even if it looks like a small function. Create it fresh when tests need isolation, and share it only when testing reuse. This is a practical bridge between functional and object-oriented thinking: state exists wherever a reference is retained, not only inside a class declaration.

Use these questions when reviewing a design: what can vary, what must stay substitutable, who owns state, and when is it released or refreshed? The answers tell you whether plain data, a callback, composition, inheritance, or an interface is the most useful mechanism. Syntax comes after that decision.
