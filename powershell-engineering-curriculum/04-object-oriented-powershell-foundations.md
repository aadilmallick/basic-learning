# Stage 4 — Object-oriented foundations: state, behavior, and invariants

You already use objects whenever you read a process, manipulate a URI, or inspect a REST response. Defining a class adds the ability to name your own kind of object and give its instances consistent data and behavior. This chapter uses PowerShell 7.4+ and complete offline examples. Run class examples in fresh processes when editing their definitions; class reload limitations are covered in stage 7.

## 4.1 The problem a class solves

Imagine four functions that each accept `Id`, `Number`, `Status`, and `FinishTime`. Each function repeats checks and interprets status slightly differently. A class can collect a stable concept into one type, so the interpretation travels with the data. The benefit comes from a coherent model, not from replacing every function with a method.

A class is a type definition. An instance is a particular object created from that definition. State is the data an instance currently holds. Behavior is the set of operations it offers. An invariant is a rule that should remain true whenever the object is considered valid—for example, a scan limit must be positive.

An object is not necessarily a real-world physical thing. `BuildObservation`, `ScanOptions`, and `ReportSummary` can all be useful concepts. Conversely, “the whole reporting script” is usually too broad a responsibility for one class. A class that authenticates, retrieves builds, analyzes streaks, and writes HTML simply relocates the original coupling.

## 4.2 Define a small class and inspect an instance

**Offline example 1 — give a build observation a name and behavior.**

```powershell
class BuildObservation {
    [string]$Id
    [string]$Number
    [string]$Status

    BuildObservation([string]$id, [string]$number, [string]$status) {
        if ([string]::IsNullOrWhiteSpace($id)) { throw 'Build ID is required.' }
        $this.Id = $id
        $this.Number = $number
        $this.Status = $status.ToUpperInvariant()
    }

    [bool] IsRed() {
        return $this.Status -in @('FAILURE', 'ERROR')
    }

    [string] ToString() {
        return '{0} #{1}: {2}' -f $this.Id, $this.Number, $this.Status
    }
}
$build = [BuildObservation]::new('1001', '2026.11.12.1', 'failure')
$build.IsRed()
$build.ToString()
$build | Get-Member
```

`class` declares the type. The constructor has the same name and no return type. `$this` identifies the instance being initialized or used. `[bool] IsRed()` declares a method with a Boolean result. `[string] ToString()` supplies a useful textual representation; callers should still use properties for structured reporting.

The constructor normalizes status to uppercase. That is a convenience, not a full domain guarantee: the public `Status` property can later be reassigned. `Id` can also be changed to an empty string. A valid constructor does not make a mutable object permanently valid. We will make the enforcement tradeoff explicit rather than claiming the syntax gives C#-style access control.

PowerShell converts a null argument to an empty string for this string parameter, so the example's normalization is safe for null in this specific signature. Nevertheless, silently accepting an unknown empty status may be a poor domain policy. A production mapper should decide which external fields are required before constructing the model.

## 4.3 Properties describe state; methods express operations

Use a property when callers need a value. Use a method when an operation has inputs, meaningful computation, a possible effect, or a useful domain name. `Status` is data; `IsRed()` interprets it. `SaveHtml()` would perform an effect and therefore deserves a name that makes the write visible.

A class method differs from an ordinary PowerShell function. Methods declare return types, and methods returning values need explicit return statements. Do not assume every unassigned expression becomes the method result as it would in a function. Void methods use `[void]` and exist for effects or state changes. Microsoft documents these rules in [class methods](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes_methods).

Keep method dependencies visible. A method that quietly reads `$global:TeamCityToken` is not well encapsulated merely because it is inside a class. The dependency has moved into a harder-to-see place. Constructor arguments, method arguments, or explicitly owned collaborators give you a clearer contract.

## 4.4 Constructors, defaults, and overloads

When you declare an explicit constructor, provide every construction form you intend to support. Do not assume a parameterless constructor remains available automatically. An overload is another method or constructor with a distinguishable parameter signature; it is not a PowerShell parameter set.

**Offline example 2 — two deliberate initialization paths.**

```powershell
class ScanWindow {
    [int]$MaximumBuilds

    ScanWindow() {
        $this.MaximumBuilds = 100
    }

    ScanWindow([int]$maximumBuilds) {
        if ($maximumBuilds -lt 1 -or $maximumBuilds -gt 500) {
            throw [ArgumentOutOfRangeException]::new('maximumBuilds')
        }
        $this.MaximumBuilds = $maximumBuilds
    }

    [string] Describe() {
        return "Inspect up to $($this.MaximumBuilds) recent builds"
    }
}
[ScanWindow]::new().Describe()
[ScanWindow]::new(25).Describe()
```

The default is explicit and the configured construction path validates its input. The two constructors repeat little enough that the example stays readable. If initialization grows, call a shared internal method rather than letting the paths diverge.

Do not rely on overloads that differ only in ways PowerShell's automatic conversion makes ambiguous. A public advanced-function factory can offer named parameters and validation, then call one unambiguous constructor internally. That gives users a familiar interface and keeps the model focused on representing valid state.

Property initializers are useful for ordinary defaults, but expensive work in construction is often surprising. Creating a client object should not need to contact TeamCity merely to prove the server is reachable. Network operations have timeouts, credentials, and retry behavior that deserve an explicit operation boundary.

## 4.5 Encapsulation means controlling how state is used

PowerShell supports `hidden` members, but `hidden` is not a security or true privacy boundary. Callers can still access a hidden member by name, and serializers may expose it. Use it to reduce ordinary display noise, not to promise protection of a token.

**Offline example 3 — an intention-revealing update method.**

```powershell
class ReportCounter {
    hidden [int]$redCount

    ReportCounter() { $this.redCount = 0 }

    [void] RecordRedBuild() {
        $this.redCount++
    }

    [int] GetRedCount() {
        return $this.redCount
    }
}
$counter = [ReportCounter]::new()
$counter.RecordRedBuild()
$counter.RecordRedBuild()
$counter.GetRedCount()
$counter.redCount = -5
$counter.GetRedCount()
```

The outputs `2` and `-5` deliberately demonstrate the limitation. The method communicates the intended way to update the counter, but the caller can bypass it. For cooperative internal code, that convention may be sufficient. For a shared library requiring stronger guarantees, a C# type with private state and read-only properties can be a better fit.

Encapsulation also means reducing what callers need to know. A client can expose `GetBuildHistory()` while keeping HTTP headers and pagination mechanics behind its interface. The caller should depend on the operation's documented result, not on the exact cache dictionary or request-building implementation.

Invariants spanning several properties are especially awkward with unrestricted public mutation. If `RedCount`, `GreenCount`, and `TotalCount` are all independently writable, inconsistent combinations are easy. Calculate derived totals from authoritative data, or create a result snapshot once and treat it as read-only by convention. Stage 6 shows a stricter C# alternative.

## 4.6 Reference identity, aliasing, and snapshots

Variables containing reference-type objects can point to the same instance. Assignment generally copies the reference, not a deep clone. This matters when a cache returns an object that another function later modifies for display.

**Offline example 4 — see shared state before it causes a cache bug.**

```powershell
$original = [pscustomobject]@{
    Name = 'Backend'
    Tags = [Collections.Generic.List[string]]::new()
}
$alias = $original
$alias.Name = 'Changed'
$alias.Tags.Add('red')
$original.Name
$original.Tags.Count

$snapshot = [pscustomobject]@{
    Name = $original.Name
    Tags = @($original.Tags.ToArray())
}
$original.Tags.Add('urgent')
$snapshot.Tags.Count
```

The first object changes through its alias. The snapshot copies the name value and creates an independent array for tags, so its tag count remains one. This is a deliberately chosen copy, not a universal deep-cloning mechanism.

`PSObject.Copy()` and hashtable cloning do not recursively duplicate every nested object. A JSON round trip changes types and may lose methods or precision. Prefer an explicit projection when building a report snapshot: select the properties you need and decide how nested collections should be copied.

Value types such as integers and many date structs have different copying behavior from reference types. You do not need a full memory model to use them well; you do need to know whether changing one variable can affect another caller's view. When in doubt, make a tiny experiment like this one and inspect the result.

## 4.7 Nullability and time are modeling choices

A build may have no trustworthy finish date. A nonnullable `[datetime]` property has a default value that can be mistaken for a real ancient timestamp. `[Nullable[DateTimeOffset]]` can represent a known instant or absence. Keeping an offset-aware instant also avoids silently tying analysis to the machine's local timezone.

**Offline example 5 — retain an instant until presentation.**

```powershell
class DatedObservation {
    [string]$Id
    [Nullable[DateTimeOffset]]$FinishedAt

    DatedObservation([string]$id, [Nullable[DateTimeOffset]]$finishedAt) {
        $this.Id = $id
        $this.FinishedAt = $finishedAt
    }

    [string] FormatUtc() {
        if ($null -eq $this.FinishedAt) { return 'Unknown' }
        return $this.FinishedAt.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
    }
}
$known = [DatedObservation]::new('1001', [DateTimeOffset]::Parse('2026-11-12T09:00:00-05:00'))
$unknown = [DatedObservation]::new('1002', $null)
$known.FormatUtc()
$unknown.FormatUtc()
```

The known date renders as 14:00 UTC; the unknown date remains `Unknown`. The stored value is not a preformatted string. A different renderer can choose a viewer timezone without changing analysis.

Absence also has a reason. A missing timestamp because the server omitted an optional field differs from an invalid timestamp that failed parsing. A small model may represent both as null, but a richer scan can attach diagnostics. Do not add a complicated type hierarchy before the application needs the distinction; do make the loss of information deliberate.

## 4.8 Equality and identity should be explicit

Two instances with the same property values are not automatically interchangeable as dictionary keys or equal domain entities. A build ID identifies a TeamCity build; a configuration ID identifies a configuration. A display name is a label that can change.

For report joins and caches, use explicit stable keys rather than expecting a custom class's default equality behavior to match your domain. If you implement value equality, define the intended fields and hash-code behavior together. C# provides familiar tools for that; in PowerShell application code, a dictionary keyed by string IDs is often simpler and clearer.

The same distinction applies to report rows. Two observations for the same pipeline at different times are different observations even though they refer to the same pipeline entity. A `PipelineId` plus a scan timestamp can express that relationship without pretending the report row is the mutable pipeline itself.

## 4.9 When a class is useful, and when an object bag is enough

| Representation | Good fit | Main cost |
|---|---|---|
| `PSCustomObject` | REST adapters, projections, short-lived report rows | Shape and rules need explicit validation |
| PowerShell class | Named models, stateful clients, cohesive domain methods | Reloading and module type visibility need care |
| C# class | Strong access control, stable shared contracts, efficient algorithms | Build, assembly, and version management |
| Hashtable | Options, lookup tables, request splats | Easy to confuse optional keys with a schema |

Choose based on the model's responsibilities and consumers. A class with fifteen public properties and no behavior can still be useful for type identity, but it may offer little advantage over a validated projection. A stateful client with per-server caches often gains more from a class because ownership is clear.

Keep transport objects separate from domain objects. TeamCity's JSON property names and optional nested structures belong to its API. A mapper should turn them into the smaller, stable shape your analyzer needs. This prevents an API-field change from spreading through every method and renderer.

## 4.10 Validation attributes can constrain individual assignments

Public mutation is not always completely unconstrained. PowerShell class properties can carry supported validation attributes. A range check can reject an out-of-range assignment after construction. This is useful for local rules, but it still does not create immutability or solve invariants spanning several properties.

**Offline example 6 — validate a mutable property deliberately.**

```powershell
class ValidatedScanOptions {
    [ValidateRange(1, 500)]
    [int]$MaximumBuilds = 100

    ValidatedScanOptions([int]$maximumBuilds) {
        $this.MaximumBuilds = $maximumBuilds
    }
}
$options = [ValidatedScanOptions]::new(25)
$options.MaximumBuilds = 50
$options.MaximumBuilds
try { $options.MaximumBuilds = 0 }
catch { 'Rejected an out-of-range assignment' }
$options.MaximumBuilds
```

The valid assignment changes the property to fifty. The invalid assignment is rejected and the previous value remains. This is a stronger local rule than constructor-only validation. Conversion can still occur before validation, so a string representing a valid integer may be accepted as that integer.

Now consider two dates, `StartedAt` and `FinishedAt`. Each might be a valid timestamp independently while their combination is invalid because finish precedes start. A property-level range attribute cannot express that relationship conveniently. A constructor or update method can validate both together, and a read-only C# model can prevent callers from bypassing the update path.

Choose the enforcement level based on who consumes the model. An internal report projection may be trusted by convention and validated once at its creation boundary. A widely reused library type benefits from stronger guarantees because many callers can create or mutate it independently. Neither choice is automatically more object-oriented; the question is whether the model's promises are actually enforced where needed.

Also distinguish validation from normalization. Converting status to uppercase chooses a canonical representation. Rejecting a blank required status enforces validity. Classification into red, green, or other applies policy. Keeping these operations conceptually separate helps you decide which belongs in the transport mapper, model, or analyzer.

## 4.11 Applying OOP to the reporting script

The uploaded script produces rows with raw status, derived health, latest-build details, failure-streak details, and formatted date text. Those are several layers combined. A cleaner design first builds observations, then analyzes them into results, then formats those results for HTML.

Useful candidate types include a client owning endpoint and cache state, a build observation holding an ID/status/instant, and a health result holding classification plus evidence confidence. The HTML renderer can remain a pure function. OOP does not require turning the renderer into an object if it has no meaningful persistent state.

One particularly important invariant is semantic: an unknown failure boundary must not be presented as an exact start. A property such as `BoundaryObserved` communicates that rule more reliably than inspecting whether a formatted string happens to start with “At least since.” Model the evidence first, then choose the wording.

This is the central payoff of classes: they can give important concepts explicit names and operations. Use that clarity to reduce hidden assumptions, not to add ceremony. The next chapter extends the model through composition and carefully chosen inheritance.

See Microsoft's [class reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes), [properties reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes_properties), and [constructors reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes_constructors) for formal syntax and limitations.

## 4.12 Design a health result from its meaning

Begin with the questions a report must answer. What was the latest observed status? Is the current pipeline classified red? How many consecutive red observations were seen? What is the oldest red timestamp in that prefix? Was a non-red boundary observed? These questions suggest a coherent result object.

Now distinguish authoritative and derived values. Raw status and finish time come from observations. Health classification comes from a policy. The red-prefix count and oldest red timestamp come from the algorithm. A formatted label comes from presentation. Storing all these values can be convenient, but each additional independently writable property permits inconsistent combinations.

For instance, a row with `Health = GREEN`, `IsRed = true`, and `RedBuildCount = 4` is structurally possible in an unconstrained property bag. A typed class with public setters can permit the same contradiction. Type annotations alone do not establish relationships between properties. You need either controlled construction, derived getters or methods, validation, or a documented immutable snapshot convention.

A small report application can calculate one result object in a pure function and never mutate it afterward. That is often sufficient and keeps the code straightforward. A shared library used by many independent callers may justify a C# constructor that accepts only authoritative inputs and exposes derived read-only results. The difference is the strength of enforcement required, not whether one representation looks more sophisticated.

Do not force every derived value into a method. Recomputing a streak on every property access would be surprising if it also read mutable history. Prefer analyzing a stable observation snapshot once, then exposing the result as data. Methods are useful for coherent operations, but an already calculated report result is naturally data-oriented.

Time is part of identity too. A pipeline entity persists while its health observations change. A result describes one scan moment and one selection policy. Keeping `GeneratedAt`, scope, and source metadata in a surrounding scan envelope avoids confusing a transient report result with the pipeline's permanent state.

## 4.13 Constructors, factories, and failure should cooperate

A constructor establishes an object's initial state. A factory gives callers an idiomatic and potentially richer creation interface. The factory can validate user-facing arguments, select defaults, and normalize a URI, while the constructor protects the internal invariants it must always enforce. Do not rely on only the factory if other code can call the constructor directly and bypass crucial checks.

At the same time, avoid duplicating a large set of rules in both places. Put shared invariant logic in one place and let the public layer translate user input into the required representation. For example, the factory may accept a server root and produce a normalized REST-root URI. The constructor can require that normalized form rather than reimplement every possible input spelling.

Construction failure should leave no half-initialized object published to callers. Validate inexpensive local rules before allocating expensive resources. If construction must allocate something disposable, release it if later initialization fails. Better still, keep network activity out of construction so object creation does not have hidden retry and timeout behavior.

Factories are also a useful module boundary. A caller can dynamically import `TeamCityAPI` and call `New-TeamCityClient` without referring to a custom type name in its own source. The returned instance still has methods and state. This is real object-oriented use even though the public entry point is an advanced function.

## 4.14 Avoid accidental object protocols

An object protocol is the set of operations and ordering rules a caller must follow. Some protocols are explicit, such as “create, write, dispose.” Others arise accidentally: “set the server, then set the token, then clear the cache, then call initialize, then fetch.” The latter is easy to misuse because the object can spend much of its lifetime in invalid intermediate states.

Prefer construction that supplies required configuration together. If changing the server invalidates the cache, consider creating a new client rather than allowing arbitrary server mutation. If a report result is a snapshot, avoid adding methods that mutate its observation history after analysis. Clear lifetime rules reduce the number of states every method must handle.

Public properties are convenient in PowerShell, but convenience should not obscure ownership. A client exposes its normalized root for inspection in the teaching implementation; callers are expected to treat it as configuration. A stricter production type can make that property read-only. The curriculum describes this convention openly so you can decide when stronger enforcement is worth the additional C# packaging.

The practical objective is not to prevent every imaginable misuse inside one process. It is to make intended use obvious, reject important invalid states, and keep responsibilities coherent. Once those goals are met, classes become a helpful way to carry meaning and ownership through the application rather than an extra syntax layer around existing globals.

Be particularly careful when mutable objects become dictionary keys. If equality or hash behavior depends on properties that later change, lookup semantics can become surprising. For this report, stable string IDs are simpler keys than mutable pipeline objects. Keep identity separate from the changing observations attached to that identity, and use snapshots for report data.
