# Stage 6 — PowerShell and C#: use .NET deliberately

PowerShell already runs on .NET. You can use many .NET APIs directly without writing a line of C#. C# becomes useful when a responsibility benefits from stronger access control, a stable typed contract, a compiled algorithm, or an existing library. This chapter develops that decision before showing compilation and assembly loading. Examples target PowerShell 7.4+ and the compatible .NET runtime it hosts.

## 6.1 The boundary is a design choice

Consider a client that retrieves JSON, an analyzer that computes failure streaks, and a renderer that creates HTML. PowerShell is effective at orchestration and command interfaces. A small C# model can enforce read-only state. A C# algorithm can help when profiling identifies a hot loop. Moving all three layers into a large `Add-Type` string would increase complexity without necessarily improving correctness.

Cross-language code has a cost: source organization, compilation, type loading, dependency versions, debugging, and distribution. Use the boundary to isolate a responsibility with a clear input and output. Prefer coarse operations over calling a C# method once per character or property from a large PowerShell loop.

Windows PowerShell 5.1 uses .NET Framework; PowerShell 7 uses modern .NET. Assemblies compiled for one environment may not work in the other. A PowerShell version number alone is not a universal assembly-compatibility promise. State supported targets and validate in the actual runtime used by the TeamCity agent.

## 6.2 Use the .NET library before writing a wrapper

**Offline example 1 — useful APIs already available.**

```powershell
$instant = [DateTimeOffset]::ParseExact(
    '20261112T090000-05:00',
    "yyyyMMdd'T'HHmmsszzz",
    [Globalization.CultureInfo]::InvariantCulture
)
$instant.ToUniversalTime().ToString('O')
[Net.WebUtility]::HtmlEncode('<Backend & API>')
[uri]::EscapeDataString('buildType:(id:Backend_Build),count:100')
$builder = [Text.StringBuilder]::new()
[void]$builder.AppendLine('<h1>Pipeline health</h1>')
[void]$builder.AppendLine('<p>Example</p>')
$builder.ToString()
```

These APIs solve distinct problems. `DateTimeOffset` retains an instant and offset. `HtmlEncode` makes text safe in ordinary HTML text and quoted attribute contexts; it is not a URL-scheme validator. `EscapeDataString` encodes a query component; it does not validate TeamCity's nested locator grammar. `StringBuilder` accumulates text without repeatedly rebuilding the whole string.

The culture argument makes date parsing independent of the machine's regional settings. Method overloads differ in parameter types and counts. If a call fails unexpectedly, inspect the API signature and explicitly cast ambiguous arguments rather than guessing. PowerShell's argument conversion is convenient but can select an unintended overload.

## 6.3 Generics and collection contracts

Generic types specify the element or key/value types in brackets. `[List[string]]` holds strings; `[Dictionary[string, object]]` maps string keys to values. Fully qualified names keep examples clear without requiring namespace imports.

**Offline example 2 — choose collection behavior explicitly.**

```powershell
$ids = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
[void]$ids.Add('Backend_Build')
[void]$ids.Add('Backend_Build')
[void]$ids.Add('backend_build')
$ids.Count

$cache = [Collections.Generic.Dictionary[string, object]]::new(
    [StringComparer]::Ordinal
)
$cache['ProjectA'] = [pscustomobject]@{ Name = 'Backend' }
$value = $null
if ($cache.TryGetValue('ProjectA', [ref]$value)) { $value.Name }
```

The set count is two because comparison is explicitly case-sensitive and duplicate insertion does not add another element. `HashSet.Add()` returns a Boolean, so `[void]` prevents that implementation detail from leaking into a function's data output.

`[ref]` supplies a reference argument for the dictionary method's output parameter. It is an interop mechanism, not a recommendation to mutate many function arguments. A PowerShell function normally returns structured data instead. Use reference parameters when calling APIs that require them.

Choosing a generic collection does not freeze its contents or make it thread-safe. A dictionary of objects still holds references to mutable objects. Its comparer determines key semantics; the element type determines accepted values. These are separate decisions that should match the model.

## 6.4 Compile a small C# type with Add-Type

**Offline example 3 — an immutable observation with a clear invariant.**

```powershell
$source = @'
using System;

namespace Curriculum.Interop {
    public sealed class BuildSnapshot {
        public string Id { get; }
        public string Status { get; }
        public DateTimeOffset? FinishedAt { get; }

        public BuildSnapshot(string id, string status, DateTimeOffset? finishedAt) {
            if (String.IsNullOrWhiteSpace(id))
                throw new ArgumentException("Build ID is required.", nameof(id));
            Id = id;
            Status = (status ?? "").ToUpperInvariant();
            FinishedAt = finishedAt;
        }

        public bool IsRed() {
            return Status == "FAILURE" || Status == "ERROR";
        }
    }
}
'@
Add-Type -TypeDefinition $source -Language CSharp
$build = [Curriculum.Interop.BuildSnapshot]::new(
    '1001', 'failure', [DateTimeOffset]::Parse('2026-11-12T14:00:00Z')
)
$build.IsRed()
$build.Status
```

The single-quoted here-string passes C# source literally. `public` makes the type and members accessible to PowerShell. `sealed` prevents inheritance. The properties have getters but no setters, and their values are assigned in the constructor. `DateTimeOffset?` is a nullable value type, allowing absence without an invented timestamp.

The constructor checks the ID before accepting the object. C#'s `??` handles a null status and `||` combines Boolean conditions. These operators belong to C# inside the source string; the surrounding PowerShell interpreter does not parse the C# body as PowerShell.

The type is effectively immutable here because strings and `DateTimeOffset` do not expose mutable nested collections. A getter-only property containing a mutable list would still permit mutation through that list. Read-only access to a reference is not deep immutability.

`Add-Type` compiles and loads the type into the process. It is not an isolated sandbox. Only compile source you intend to execute. The cmdlet's compilation options and duplicate-type behavior are documented in [Add-Type](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type).

## 6.5 Type loading is not hot reloading

Once a named type is loaded, editing the source does not replace every existing instance or unload its assembly. PowerShell 7 avoids recompiling certain already existing type definitions; this can make a changed source appear to have no effect. Use a fresh process when verifying a modified C# type.

For a tiny demonstration, `if (-not ('Namespace.Type' -as [type])) { Add-Type ... }` avoids duplicate work. It is not a version-management strategy: the old implementation may still be loaded under that name. A production module should use a versioned assembly with a deliberate deployment layout and process lifecycle.

`using namespace` shortens type names; it does not load an assembly. `using assembly` supplies an assembly dependency at the appropriate language-loading boundary. `Add-Type -Path` loads a compiled assembly at runtime. PowerShell class declarations that inherit or implement custom .NET types require those types to be available when the class is defined; loading them later in the same file can be too late.

For reliable distribution, keep compiled contracts and PowerShell consumers in separately loadable files and test from a fresh process. Do not use successful execution in a long-lived editor session as proof that a clean CI agent can resolve all types.

## 6.6 Define a typed contract only when it earns its cost

A .NET interface can make a cross-language boundary precise. Inheritance and implementation require the assembly to be available before dependent class declarations. A simple C# implementation avoids that loading complication in this self-contained example.

**Offline example 4 — a contract plus a deterministic implementation.**

```powershell
Add-Type -TypeDefinition @'
namespace Curriculum.Contracts {
    public interface IStatusClassifier {
        string Classify(string status);
    }

    public sealed class StatusClassifier : IStatusClassifier {
        public string Classify(string status) {
            switch ((status ?? "").ToUpperInvariant()) {
                case "SUCCESS": return "GREEN";
                case "FAILURE":
                case "ERROR": return "RED";
                default: return "OTHER";
            }
        }
    }
}
'@
$classifier = [Curriculum.Contracts.StatusClassifier]::new()
$classifier -is [Curriculum.Contracts.IStatusClassifier]
$classifier.Classify('UNKNOWN')
```

The results are `True` and `OTHER`. The interface guarantees a method signature, while tests must still verify behavior. It cannot prove that `Classify('FAILURE')` returns the right answer. Types reduce some categories of mistake; they do not replace examples, invariants, or tests.

An interface is particularly useful when multiple implementations are maintained independently or other .NET code consumes the contract. For a small internal PowerShell module, a script block with a documented signature may offer the same practical testability with less packaging effort.

## 6.7 JSON is a boundary, not object cloning

TeamCity JSON becomes PowerShell objects through deserialization. Those objects represent transport data, not your custom live C# or PowerShell instances. Converting an object to JSON and back retains selected data, not methods, private state, constructor invariants, or full type identity.

**Offline example 5 — map transport data deliberately.**

```powershell
$json = '{"id":1001,"status":"FAILURE","finishDate":"20261112T140000+0000"}'
$dto = $json | ConvertFrom-Json
$dateText = $dto.finishDate -replace '([+-]\d{2})(\d{2})$', '$1:$2'
$finishedAt = [DateTimeOffset]::ParseExact(
    $dateText,
    "yyyyMMdd'T'HHmmsszzz",
    [Globalization.CultureInfo]::InvariantCulture
)
[pscustomobject]@{
    Id = [string]$dto.id
    RawStatus = [string]$dto.status
    FinishedAt = $finishedAt
}
```

The mapper converts ID to an opaque string and parses the timestamp into a proper instant. That avoids assuming numeric build IDs will fit in a small integer forever. External JSON data often uses numbers where an application should treat the field as an identifier rather than an arithmetic quantity.

When writing JSON, choose `ConvertTo-Json -Depth` deliberately. A shallow default can truncate nested information. Serialize a small explicit projection rather than every property of a client or domain object. Never serialize a client containing credentials merely because it is convenient to inspect.

If you need a stable file format, specify field names, timestamp format, null meanings, and schema version. An implementation type's default serializer output is not a durable contract by itself. This matters when fixtures become long-lived regression evidence.

## 6.8 Exceptions and async APIs across the boundary

Exceptions raised by .NET calls appear through PowerShell error records and may be wrapped by invocation-related exceptions. Inspect the actual exception and inner-exception chain when classifying a failure; do not assume the outermost type always matches the original C# exception. Preserve the original record when rethrowing.

Many modern .NET libraries expose `Task`-returning methods. PowerShell does not have a general C#-style `await` keyword for ordinary scripts. Calling `.GetAwaiter().GetResult()` can synchronously obtain the result, but it blocks the current thread and needs careful resource and cancellation handling. Do not present synchronous waiting as automatic asynchronous scaling.

For ordinary REST requests, `Invoke-RestMethod` often gives a clearer PowerShell interface. Use `HttpClient` directly when you need capabilities the cmdlet does not expose or when integrating with a larger .NET library. Manage client lifetime deliberately and avoid creating disposable network infrastructure once per tiny operation without considering reuse.

## 6.9 Performance: measure the complete path

A C# loop can be faster than a PowerShell loop, but a TeamCity report is often dominated by network latency. Rewriting classification of one hundred status strings may save almost nothing compared with reducing redundant project requests. Measure request count, response size, wall-clock time, and rendering time before choosing an optimization.

**Offline example 6 — measure one deterministic transformation.**

```powershell
$statuses = @('SUCCESS', 'FAILURE', 'ERROR', 'UNKNOWN') * 1000
$measurement = Measure-Command {
    $red = 0
    foreach ($status in $statuses) {
        if ($status -in @('FAILURE', 'ERROR')) { $red++ }
    }
}
[pscustomobject]@{ Red = $red; Milliseconds = $measurement.TotalMilliseconds }
```

The red count is 2000. The timing varies by runtime, machine, and warmup. One measurement is not a benchmark. For a meaningful comparison, separate compilation cost, warmup, repeated runs, input conversion, and output creation. Report the workload and environment rather than claiming C# is universally a fixed number of times faster.

## 6.10 Put a cohesive algorithm across the boundary

A useful C# operation accepts a small collection and returns one meaningful result. This keeps conversion overhead and ownership rules visible. The following algorithm deliberately does not interpret dates, call TeamCity, or format HTML. It only counts a leading red prefix, so its semantics are easy to compare with the PowerShell version.

**Offline example 7 — a typed collection operation.**

```powershell
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;

namespace Curriculum.Algorithms {
    public static class RedPrefix {
        public static int Count(IEnumerable<string> newestFirstStatuses) {
            if (newestFirstStatuses == null)
                throw new ArgumentNullException(nameof(newestFirstStatuses));
            int count = 0;
            foreach (string raw in newestFirstStatuses) {
                string status = (raw ?? "").ToUpperInvariant();
                if (status != "FAILURE" && status != "ERROR") break;
                count++;
            }
            return count;
        }
    }
}
'@
$statuses = [string[]]@('failure', 'ERROR', 'SUCCESS', 'FAILURE')
[Curriculum.Algorithms.RedPrefix]::Count($statuses)
```

The result is two. `IEnumerable<string>` describes an iterable sequence rather than requiring a particular list implementation. A string array satisfies that contract. `static` makes the operation belong to the type because it owns no per-instance state. `ArgumentNullException` distinguishes an absent sequence from a legitimate empty sequence.

The null-element behavior is a deliberate policy: a null item becomes an empty status and stops the prefix. A stricter domain model might reject it. The fact that the code compiles does not choose the right policy for you; tests and the boundary contract still matter.

If you expose this algorithm from a module, wrap it in an advanced function that accepts PowerShell input and documents ordering. The public command can remain stable while the implementation moves between PowerShell and C#. This is a useful form of replaceability because callers depend on the operation rather than the language used internally.

Do not use a performance claim to justify the move without measurement. For a hundred statuses per pipeline, network retrieval may dominate completely. The stronger reason might be sharing one tested policy with another .NET application. That is a valid benefit even when total report time does not change.

Assembly distribution also requires deciding where the source of truth lives. Keep the C# source, project configuration, and compiled output traceable to one version. Avoid manually editing a DLL in a module directory while leaving source unchanged. A fresh-process import test should exercise the same artifact that users receive, including all referenced dependencies.

## 6.11 Choosing a practical packaging strategy

For learning, inline `Add-Type` keeps the full example visible. For a reusable module, a separate `.cs` file improves editing and review. For a stable shared library, a compiled assembly with explicit target frameworks, package metadata, and CI is usually more maintainable. These are progressive choices, not mandatory steps for every script.

Avoid downloading and loading arbitrary assemblies during module import. Installation and dependency resolution should be explicit and repeatable. Import should establish definitions, not surprise the caller with an unbounded network operation. Use pinned, reviewed dependencies appropriate to the organization and supported runtime.

The final teaching refactor stays mostly in PowerShell so its core boundaries remain visible. It includes a small client class and ordinary data projections. This chapter gives you the tools to replace a boundary with C# later when there is a concrete reason, while preserving the public command contract.

The useful question is always “which rule becomes clearer or safer here?” A read-only C# snapshot can enforce an invariant. A compiled classifier can serve multiple .NET consumers. A direct .NET HTML encoder can avoid custom escaping bugs. Those are specific benefits; using C# merely to make a script appear more advanced is not.

## 6.12 Read a C# model as a contract, not unfamiliar punctuation

Take the `BuildSnapshot` example apart in dependency order. The namespace gives the type a qualified name and reduces collisions with other libraries. The class declaration introduces a reference type. Public visibility allows external callers, including PowerShell, to construct and inspect it. Sealing the class means its behavior cannot be changed through derivation.

Each getter-only property exposes a value without exposing a normal setter. The constructor receives the values needed to establish a valid instance. The ID check rejects an unusable identity before the object is returned. Status normalization chooses one internal spelling. The nullable date retains the distinction between a known instant and absence.

The `IsRed` method expresses a policy in one place. It compares strings using the exact canonical values established by construction. This arrangement is coherent because the status cannot later be changed through a public setter. If you added a setter that skipped normalization, the method's assumptions would need review.

Now compare it with the PowerShell class from stage 4. Both name the concept and offer a method. The C# type adds stronger access control over updates. The PowerShell type is easier to define and modify inside a script-centric workflow. Neither automatically validates server selection, branch scope, or the meaning of a finish timestamp. Those are different contracts outside the model.

This way of reading code helps you understand unfamiliar libraries. Locate construction, accepted inputs, exposed state, operations, and ownership. Then inspect exceptions and lifetime requirements. You do not need to memorize every C# language feature before using a small well-defined .NET type from PowerShell.

## 6.13 Design conversions explicitly at both sides

Crossing into C# may trigger PowerShell conversions. A string array can satisfy an `IEnumerable<string>` parameter. A textual number can become an integer. Null can be accepted or rejected depending on the target type and implementation. These conveniences reduce boilerplate but can hide assumptions if the API is overloaded broadly.

Prefer clear parameter types and unambiguous method names. If an API has overloads accepting both a string and a character array, explicitly construct the representation you intend. When calling a generic method is awkward, a small non-generic wrapper can be clearer than relying on complicated reflection inside application code.

Crossing back also needs a contract. A .NET collection written from a PowerShell function may be enumerated into individual output objects. A method returning an array is not automatically a promise that the wrapper emits the array as one item. Decide whether the public PowerShell command returns a sequence or an envelope and test zero, one, and many elements.

Exceptions are another conversion boundary. A C# argument exception may appear inside a PowerShell invocation error record. A wrapper should preserve enough structure for diagnosis while presenting a useful command-level message. Avoid converting every exception into null, because that erases the difference between invalid data and a valid empty result.

For timestamps, keep an instant type until serialization or display. When writing fixtures, use an explicit invariant format. When writing HTML, choose a visible timezone label. A C# model containing `DateTimeOffset` helps preserve information, but a careless PowerShell projection can still discard it by taking `.LocalDateTime` too early.

## 6.14 Decide whether compiled code should be a source dependency or an artifact

Inline compilation is convenient for a self-contained lesson. It is less attractive when a module is imported frequently, several processes start simultaneously, or the C# source has independent tests and consumers. A compiled library lets CI build once and distribute a reviewed artifact, but it introduces target-framework and assembly-version choices.

If you keep source compilation, put the source in a separate file and define when compilation happens. Import-time compilation should be deterministic and local; it should not download packages or depend on whatever source happens to be present in a temporary directory. Record compiler errors clearly, and test from a clean process so a previously loaded type cannot hide a failure.

If you distribute an assembly, include the files it actually needs and test the package layout. An assembly that loads on a developer machine may rely on a dependency installed elsewhere. A target-framework label does not prove every referenced API is available in every host. Validate the supported PowerShell/runtime combinations explicitly.

Keep the public PowerShell interface stable across the choice. Callers should continue using a named command with documented parameters and output. They should not need to know whether classification is implemented in a PowerShell loop or a compiled method. This preserves the option to move code later based on measured needs.

For the TeamCity report, the first useful C# addition would often be a stable immutable observation or result contract shared with another application. The first useful performance change might instead be caching or fewer HTTP calls. Distinguishing those motivations prevents a common engineering mistake: solving a packaging problem when the actual bottleneck is network behavior, or chasing speed when the real requirement is stronger invariants.

When diagnosing a loaded-type mismatch, inspect the type's assembly identity as well as its name. Two builds of a library can expose the same namespace and class while differing in implementation or compatibility. Record the selected artifact version and restart the process before judging whether a source change took effect.
