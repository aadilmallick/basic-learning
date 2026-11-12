# Stage 1 — PowerShell's execution model: objects, output, scope, and data flow

This chapter establishes the rules that make later classes, modules, and tests predictable. Use PowerShell 7.4 or later. The verification report records the exact runtime used for this edition. Examples marked **Offline example** run without credentials or a network connection; run each block in a fresh session unless the text explicitly connects it to another block. A code block described as a fragment illustrates a local expression rather than a complete program.

## 1.1 The problem: a script can look correct and return the wrong thing

Suppose a TeamCity helper should return a build count. It calculates the right number, prints a useful message, and then returns the number. In a text-oriented mental model, the message is harmless. In PowerShell, an unassigned string is another success-stream object. A caller may receive an array containing both a string and an integer. The mistake is not arithmetic; it is a misunderstanding of the function's output contract.

PowerShell combines an interactive shell, a programming language, and access to .NET. These parts cooperate, but their rules differ. Command invocation uses parameter binding. Expressions operate on values. Pipelines transport objects. The formatting system later turns objects into visible text. Learning to distinguish these layers is more useful than memorizing isolated syntax.

An object has a type, data accessible through properties, and behavior accessible through methods. A pipeline transports references to these objects within the current process; it does not normally convert each object to a line of text. Serialization boundaries such as jobs, remoting, and JSON change that picture, as later chapters explain.

## 1.2 Values, types, properties, and methods

**Offline example 1 — inspect the values you actually have.**

```powershell
$name = 'Backend build'
$count = 42
$build = [pscustomobject]@{
    Id = '1001'
    Number = '2026.11.12.1'
    Status = 'FAILURE'
}
$name.GetType().FullName
$count.GetType().FullName
$build.Status
$build.Status.ToLowerInvariant()
$build | Get-Member -MemberType NoteProperty
```

The first two results are `System.String` and `System.Int32`. `$build.Status` reads data. `.ToLowerInvariant()` invokes a method on that string and returns a new string. It does not change the property. Strings are immutable, so assigning a changed value requires `$build.Status = $build.Status.ToLowerInvariant()`.

`[pscustomobject]@{ ... }` creates a convenient property bag from a hashtable literal. The resulting object's property names are stable for that instance, but this construction does not declare a reusable schema. Another object may omit `Status`, and the property can later receive a number. A class can give the shape a type identity; it does not automatically enforce every business rule.

The brackets in `[Math]` identify a type. `::` accesses a static member associated with that type. A dot accesses an instance member associated with a particular value. `[DateTimeOffset]::UtcNow` reads a static property; `$instant.ToString('O')` invokes an instance method. Constructors such as `[uri]::new('https://ci.example.com/')` create objects.

Type annotations often request conversion. `[int]$count = '42'` succeeds because PowerShell can convert the string. `[int]$count = 'many'` fails. Therefore “typed” does not mean “only accepts an already existing object of exactly this type.” This distinction matters when validating REST responses.

## 1.3 The pipeline carries objects; formatting is a later operation

**Offline example 2 — transform structured build data.**

```powershell
$builds = @(
    [pscustomobject]@{ Id = '101'; Status = 'SUCCESS'; Duration = 12 }
    [pscustomobject]@{ Id = '102'; Status = 'FAILURE'; Duration = 30 }
    [pscustomobject]@{ Id = '103'; Status = 'FAILURE'; Duration = 20 }
)
$failed = @($builds | Where-Object Status -eq 'FAILURE')
$failed |
    Sort-Object Duration -Descending |
    Select-Object Id, Duration
```

`Where-Object` examines each object's property, `Sort-Object` buffers input so it can order it, and `Select-Object` projects a new shape. The two output rows are build 102 with duration 30, followed by build 103 with duration 20. The table you see is a display choice, not the underlying value.

Use `Format-Table` and `Format-List` at the display boundary. They emit formatting instructions, not the original build objects. A pipeline such as `... | Format-Table | Export-Csv` therefore exports the wrong kind of objects. For a report module, return data first; let the caller choose HTML, CSV, JSON, or an on-screen table.

Streaming is also not universal. `Where-Object` can pass one matching object onward immediately. Sorting must see the collection before knowing the final order. Grouping, aggregate statistics, and many report calculations similarly require buffering. Understanding where buffering happens helps you choose whether to stream configurations or collect all rows.

## 1.4 Output cardinality: zero, one, and many

**Offline example 3 — make collection shape explicit.**

```powershell
function Get-BuildId {
    param([int]$Count)
    for ($index = 1; $index -le $Count; $index++) {
        "build-$index"
    }
}
$none = @(Get-BuildId -Count 0)
$one = @(Get-BuildId -Count 1)
$many = @(Get-BuildId -Count 3)
"Counts: $($none.Count), $($one.Count), $($many.Count)"
```

The result is `Counts: 0, 1, 3`. `@(...)` is the array subexpression operator: it collects success output and makes array handling consistent. Without it, an assignment commonly produces `$null` for no output, a scalar for one object, and an array for several objects. Some scalar values expose a convenient `Count`, but relying on that convenience is weaker than deliberately collecting a sequence.

PowerShell normally enumerates arrays written to a pipeline. Returning `@()` does not send an empty array object downstream; it usually sends no elements. If your API needs to return a collection as one object, document that explicitly and use a wrapper property, a unary comma, or `Write-Output -NoEnumerate` as appropriate. Do not make callers guess whether an array is a result container or one result item.

For report commands, the simplest contract is generally “zero or more row objects.” For a scan with metadata, use a single envelope object with properties such as `Rows`, `Failures`, and `GeneratedAt`. The envelope keeps collections and metadata together without mixing unrelated objects in one output stream.

## 1.5 Functions output expressions, not just return statements

**Offline example 4 — separate results from diagnostics.**

```powershell
function Get-FailedBuildCount {
    [CmdletBinding()]
    param([object[]]$Build = @())
    Write-Verbose "Inspecting $($Build.Count) builds"
    $failed = @($Build | Where-Object Status -in @('FAILURE', 'ERROR'))
    return $failed.Count
}
$inputBuilds = @(
    [pscustomobject]@{ Status = 'FAILURE' }
    [pscustomobject]@{ Status = 'SUCCESS' }
)
$result = Get-FailedBuildCount -Build $inputBuilds -Verbose
"Result type: $($result.GetType().Name); count: $result"
```

The result remains one integer even when verbose output is enabled. `return` ends the current function invocation and may write a value; it does not erase output already emitted. A stray string or the return value of a .NET method can still contaminate the result before the return statement.

Some collection methods return values you do not want to publish. `ArrayList.Add()` returns an index; `StringBuilder.AppendLine()` returns the builder. Suppress deliberate side effects with `[void]$builder.AppendLine(...)` or `$null = ...`. A generic `List[T].Add()` returns `void`, so it does not need suppression, although using `[void]` is harmless.

PowerShell provides success (1), error (2), warning (3), verbose (4), debug (5), and information (6) streams. Progress is separate from those numbered streams. `Write-Host` uses the information stream with host-oriented behavior. `Write-Output` writes success objects. Redirection such as `2>&1` merges errors into success output; the resulting collection now contains mixed object types. That can be useful for a diagnostic transcript but is unsuitable as a normal data interface.

## 1.6 Scope: explicit inputs beat accidental dependencies

A function can often read variables in enclosing scopes. That makes a single script convenient, but moving the function to a module may change what it can see. Assignment to a variable in a function's local scope also differs from mutating an object that the variable refers to.

**Offline example 5 — distinguish rebinding from mutation.**

```powershell
$server = 'outer'
$settings = @{ Server = 'original' }
function Set-LocalExample {
    $server = 'inner'
    $settings.Server = 'changed'
}
Set-LocalExample
$server
$settings.Server

function New-ReportLabel {
    param([string]$Server, [int]$BuildCount)
    "$Server has $BuildCount builds"
}
New-ReportLabel -Server 'ci.example.com' -BuildCount 3
```

The first two outputs are `outer` and `changed`. Assigning `$server` creates or changes a local binding. Updating the shared hashtable mutates the object found through scope lookup. This distinction explains why a cache in the original TeamCity script can be mutated from helper functions even though the helpers do not declare a cache parameter.

Prefer explicit parameters for dependencies such as server URI, token, clock, and cache. Module-private state can be reasonable when the module deliberately owns one session, but it makes multiple clients and parallel tests harder. A client object is a useful owner when each server connection needs its own configuration and cache.

`& $scriptBlock` invokes a script block with a child scope in ordinary use. Dot-sourcing `. $path` executes a script in the current scope so its definitions remain available there. Dot-sourcing is a loading tool, not a replacement for module boundaries. Modules have their own session state, which stage 7 develops carefully.

## 1.7 Collections, identity, and comparison

An array is a fixed-size sequence. Appending with `$rows += $row` can require creating a new array and copying elements. The language has evolved performance optimizations, so do not make universal timing claims; a generic list still expresses intentional accumulation clearly and works across the curriculum's PowerShell 7 baseline.

**Offline example 6 — accumulate and index explicitly.**

```powershell
$rows = [System.Collections.Generic.List[object]]::new()
$byId = [System.Collections.Generic.Dictionary[string, object]]::new(
    [StringComparer]::Ordinal
)
foreach ($id in @('Backend', 'backend')) {
    $row = [pscustomobject]@{ Id = $id; Status = 'SUCCESS' }
    $rows.Add($row)
    $byId.Add($id, $row)
}
$rows.Count
$byId.Count
@($rows | Where-Object Id -eq 'Backend').Count
@($rows | Where-Object Id -ceq 'Backend').Count
```

The results are `2`, `2`, `2`, and `1`. The dictionary explicitly uses ordinal, case-sensitive key comparison. Ordinary PowerShell string equality is case-insensitive unless you choose `-ceq`. Standard hashtables also commonly use case-insensitive string keys. Identifier semantics should be a deliberate choice rather than an accidental inheritance from a convenient container.

For comparison operators, scalar and collection left operands behave differently. `'FAILURE' -eq 'FAILURE'` is Boolean. `@('SUCCESS','FAILURE') -eq 'FAILURE'` filters matching elements. To ask whether a collection contains a value, use `-contains`, or use `-in` with the value on the left. This prevents conditions from silently depending on whether a value happened to be scalar or plural.

Avoid formatting data as a substitute for structure. A project name plus a delimiter plus a build name is a display label, not a robust identity. Project IDs and build-configuration IDs are better keys. Names can change and need not be unique across a hierarchy.

## 1.8 Null, missing properties, strict mode, and truthiness

`$null`, an empty string, an empty collection, and a missing property represent different situations. A server can legitimately return zero builds. A response missing the requested collection may indicate an incompatible response shape. Treating both as “no builds” hides errors.

**Offline example 7 — distinguish missing data from an empty value.**

```powershell
Set-StrictMode -Version Latest
$response = [pscustomobject]@{ build = @() }
$property = $response.PSObject.Properties['build']
if ($null -eq $property) {
    throw 'Response is missing the build collection'
}
$builds = @($property.Value)
"Build count: $($builds.Count)"
$optional = $response.PSObject.Properties['nextHref']
if ($null -eq $optional) { 'No continuation property' }
```

Strict mode catches several classes of mistakes, including certain uninitialized-variable and missing-property accesses. It does not validate business meaning, and `Latest` can change with the runtime. A reusable package should state its supported versions and test them; strict mode is a diagnostic aid, not a proof of correctness.

Use `$null -eq $value` when testing for null. Putting a collection on the left of `-eq` can trigger element filtering. Avoid `if ($value)` when zero or an empty string is a legitimate value. A zero failure count means a successful calculation, not absent data. Use `[string]::IsNullOrWhiteSpace()` for user-entered text and explicit collection counts for sequences.

## 1.9 Expressions, strings, and readable invocation

Single-quoted strings are literal; double-quoted strings expand variables and subexpressions. `$($build.Status)` evaluates an expression inside an expandable string. Braces delimit a variable name when punctuation follows it: `"${status}: latest result"`. Prefer single quotes for static text, especially JSON and regular expressions, so interpolation cannot change their meaning.

PowerShell command invocation and method invocation use different forms. A command takes named parameters, as in `Get-Item -LiteralPath $path`. A .NET method uses parentheses and comma-separated arguments, as in `[Math]::Round($number, 1)`. A hashtable splat, `Invoke-RestMethod @request`, expands keys into command parameters. It makes long calls easier to read than a chain of fragile trailing backticks.

The pipeline variable `$_` is context-sensitive. Inside `Where-Object`, it is the current input object; inside `catch`, it is an error record. A nested pipeline can replace the meaning you were relying on. Assign a meaningful local name when the surrounding context is important. Code that reads clearly today is easier to refactor into independent functions later.

## 1.10 Applying the execution model to the TeamCity report

The uploaded script already shows several sound choices: array subexpressions around command results, `PSCustomObject` rows, `[void]` around builder calls, defensive property access, and HTML encoding. These are not decorations. Each choice protects a boundary: collection shape, row shape, output purity, optional API data, or rendering.

Its hidden outer variables also explain why file splitting alone would be insufficient. A helper that reads `$apiRoot` and `$headers` is coupled to the script's execution environment. A renderer that reads `$MaxBuildsToScan` has an undeclared presentation dependency. The refactor must make those dependencies explicit, whether as parameters or well-owned object state.

The practical rule to carry forward is precise: decide what each command receives, what objects it emits, what state it owns, and which effects it performs. That is the foundation of modular design. Classes help only after those decisions are clear.

## 1.11 Collection shape experiments worth keeping beside your code

There is a subtle difference between collecting no output and collecting one null value. A function that emits nothing gives `@(FunctionCall).Count` equal to zero. The expression `@($null)` contains one null slot. This distinction appears when optional properties are wrapped without checking whether the property itself exists. A collection can therefore have a nonzero count while containing no usable item.

**Offline example 8 — distinguish a result envelope from its elements.**

```powershell
function Get-NoObservation { return }
$empty = @(Get-NoObservation)
$nullSlot = @($null)
$envelope = [pscustomobject]@{ Rows = @(); Complete = $true }
"Empty output: $($empty.Count)"
"Explicit null slot: $($nullSlot.Count)"
"Envelope rows: $($envelope.Rows.Count)"
$lookup = @{ Backend = 'RED'; Frontend = 'GREEN' }
@($lookup.GetEnumerator() | Sort-Object Key) |
    Select-Object Key, Value
```

The first three counts are zero, one, and zero. The hashtable example uses `GetEnumerator()` because a hashtable written to a pipeline is generally treated as one dictionary object, rather than automatically emitting its key/value entries. Strings are also usually treated as one value rather than a stream of characters. Enumeration behavior depends on the type and context; “PowerShell enumerates everything” is an unreliable rule.

An envelope is useful when the absence of rows is itself a valid completed result. The caller receives one object, can inspect `Complete`, and can iterate `Rows`. Without the envelope, no rows and no result can be indistinguishable unless errors or another channel carry the distinction.

This also explains why you should inspect data before expanding properties. `$objects.Name` uses member-access enumeration in many cases, which is convenient but can conceal missing fields and change cardinality. For a boundary that requires exactly one project ID per row, explicit iteration and validation make the contract easier to see. Convenience syntax is valuable once its shape is understood.

## 1.12 Trace one observation through the entire execution model

Consider one fictional response item with ID `103`, status `FAILURE`, and a finish timestamp. The HTTP cmdlet deserializes JSON into an object. At this point, its properties describe the transport representation: the ID may be numeric, the timestamp is text, and some fields may be absent. It is structured data, but it is not yet a validated application observation.

The adapter reads required properties, converts the ID to an opaque string, normalizes status, and parses the timestamp. The new object has a smaller, deliberate shape. This is a projection: it selects useful information and establishes conventions. The adapter should not modify the original response object merely to prepare it for display, because another consumer may still need the raw data.

The analyzer receives an array of these observations. The array represents a sequence in a documented order. It is not itself a pipeline. A `foreach` statement reads its elements directly; a pipeline can enumerate them into commands. Either approach can implement the same rule, but the choice affects streaming, buffering, and clarity. A leading-streak algorithm often reads more naturally as a loop because it deliberately stops at the first boundary.

The analyzer emits one result object. It contains a classification, count, dates, and evidence flags. An assignment captures that result. If a debug string accidentally precedes it on the success stream, the assignment now captures two objects. A later property access may use member-access enumeration and appear to work for some fields, delaying discovery of the contamination. This is why output purity is a correctness issue even when the first visible report looks plausible.

The renderer receives the result and converts selected values to text. This is the first point where the timestamp becomes a display string and the name becomes HTML-encoded text. The final HTML document is one string value, although it contains many lines. Sending that string through a pipeline does not automatically turn it into one object per line. A file-writing command then creates bytes using a chosen encoding.

This trace separates six shapes: external JSON text, deserialized transport object, normalized observation, ordered observation collection, interpreted result, and rendered document. Many script defects come from treating two adjacent shapes as interchangeable. Naming variables after their role—`response`, `observations`, `health`, `html`—helps readers see where each conversion happens.

## 1.13 Diagnose shape errors before changing the algorithm

When a command returns an unexpected result, inspect type and cardinality before rewriting business logic. A property lookup that returns several values may mean the variable contains multiple result objects. A zero count may mean no output, not a calculated zero. A table that looks right may still contain formatting records rather than the original data.

Start by assigning the value and inspecting it with `Get-Member`, `.GetType()`, and an explicit array subexpression. For potentially null values, check null first before invoking a method. Then inspect one representative object with `Format-List *` at the terminal boundary. Avoid adding `Format-List` inside a reusable helper just to make its output easier to see; that changes the helper's contract.

Next inspect where enumeration occurs. A function emitting an array usually emits its elements; a wrapper with a `Rows` property retains a collection inside one result. A nested collection may require an explicit contract about whether each inner array is a batch or an item. This matters in reporting because an accidental extra nesting level can make a loop process one collection instead of several pipelines.

Finally inspect scope. If a helper works only after another command has been run interactively, it may depend on a variable, function, or loaded type left in the session. Start a fresh process and supply explicit inputs. That experiment often explains the defect more quickly than adding more defensive branches.

These diagnostics also guide code review. Look for bare strings in data-producing functions, unsuppressed builder calls, formatting before export, implicit global configuration, and identifiers derived from names. Each pattern points to a specific contract question. You do not need to ban convenient syntax; you need to know what values it creates and which boundary receives them.

## References for specific language rules

The explanations and examples are original to this curriculum. Microsoft's references provide the formal details for [pipeline behavior](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines), [output streams](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams), [scope](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes), and [comparison operators](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators). See the verification report for which examples were executed.
