# Stage 7 — Modules, manifests, dependencies, and class loading

A module packages a public interface and its implementation behind a loading boundary. It is not merely a folder of related scripts. This chapter explains command discovery, module scope, manifests, runtime imports, parse-time type requirements, and why class development benefits from fresh processes. Use PowerShell 7.4+; the offline examples create temporary files and clean up only the files they own.

## 7.1 The problem: file splitting can preserve every hidden dependency

Suppose you move `Invoke-TeamCityGet` into `TeamCityAPI.psm1` but leave `$headers` in the calling script. The function's text is unchanged, yet its variable lookup environment has changed. The module has its own session state. A helper that depended on a script-local variable may now fail or accidentally find a different value.

The correct extraction starts with a contract: what does the module receive, what state does it own, what commands does it expose, and what objects does it return? Only then choose files. A client parameter or constructor can carry server state explicitly. A pure renderer can receive rows and metadata. Neither should depend on the caller's arbitrary variables.

Three file types matter most. A `.ps1` is a script, often invoked for an application workflow or dot-sourced during controlled loading. A `.psm1` is a script module. A `.psd1` is a restricted data file used as a module manifest. The manifest describes the module entry point, version, exports, requirements, and packaging metadata.

## 7.2 Build and import a minimal module

**Offline example 1 — observe the public boundary.**

```powershell
$moduleDirectory = Join-Path ([IO.Path]::GetTempPath()) ('CurriculumModule-' + [guid]::NewGuid())
$null = New-Item -ItemType Directory -Path $moduleDirectory
$modulePath = Join-Path $moduleDirectory 'HealthLabels.psm1'
@'
function ConvertTo-HealthLabel {
    [CmdletBinding()]
    param([string]$Status)
    switch ($Status.ToUpperInvariant()) {
        'SUCCESS' { 'GREEN'; break }
        'FAILURE' { 'RED'; break }
        default { 'OTHER' }
    }
}
function Get-InternalPalette { '#c5282f' }
Export-ModuleMember -Function ConvertTo-HealthLabel
'@ | Set-Content -LiteralPath $modulePath -Encoding utf8
try {
    Import-Module $modulePath -Force
    ConvertTo-HealthLabel -Status FAILURE
    @(Get-Command Get-InternalPalette -ErrorAction SilentlyContinue).Count
}
finally {
    Remove-Module HealthLabels -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $modulePath
    Remove-Item -LiteralPath $moduleDirectory
}
```

The outputs are `RED` and `0`. The internal palette function exists in module scope but is not exported as a caller-visible command. This is an API boundary, not a security barrier: sufficiently privileged code in the same process can inspect or invoke module internals. Its purpose is to reduce accidental coupling.

Import should normally define commands and initialize inexpensive internal state. Avoid prompting for credentials, scanning the server, writing reports, or installing dependencies merely because a user imported the module. Those effects belong to explicit commands.

An exported function can call private module functions. The caller does not need those helpers in its own scope. This is how implementation details remain replaceable while the public contract stays stable.

## 7.3 Add a manifest and explicit exports

The following is a **manifest file**, not a standalone command. Save this shape as `TeamCityAPI.psd1` beside its root module. The bundled reference implementation supplies actual manifests that can be inspected and imported.

```powershell
@{
    RootModule = 'TeamCityAPI.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'c0a17318-f369-49ae-a7f4-7f4fc59eebc1'
    Author = 'Curriculum example'
    Description = 'Read-only TeamCity reporting boundary.'
    PowerShellVersion = '7.4'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @('New-TeamCityClient', 'Get-TeamCityBuildType', 'Get-TeamCityBuildHistory')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
```

`RootModule` identifies the implementation. `ModuleVersion` is a package version, not the server version. The GUID identifies the module across releases and should remain stable for that module. `PowerShellVersion` declares a minimum; it does not prove compatibility with every newer release. `CompatiblePSEditions` identifies the intended edition and also needs real testing.

Use explicit export lists in the manifest and root module so adding a private helper does not silently expand the API. `Test-ModuleManifest -Path ...` validates manifest structure and relevant dependencies; it does not execute your entire workflow or prove semantic correctness. See Microsoft's [module manifest guidance](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests).

`RequiredModules` declares module dependencies. `RequiredAssemblies` names assembly dependencies. `ScriptsToProcess` runs scripts in the caller's session state and therefore deserves particular care; it is usually unnecessary for this curriculum's design. Do not use manifest fields as a substitute for a deliberate loading model.

## 7.4 Organize files without making order accidental

A common source layout is:

```text
TeamCityAPI/
  TeamCityAPI.psd1
  TeamCityAPI.psm1
  Public/
    Get-TeamCityBuildHistory.ps1
  Private/
    New-TeamCityRequestUri.ps1
  Tests/
    TeamCityAPI.Tests.ps1
```

The root module can dot-source selected function files using paths anchored to `$PSScriptRoot`. During development, deterministic sorted enumeration is convenient for independent function definitions. If definitions depend on types or initialization order, spell out that order rather than relying on whatever the filesystem returns.

Dot-sourcing function files inside the root module establishes definitions in module scope. It does not make classes declared in arbitrary nested files reliably visible to consumers through `using module`. Class visibility is the important exception developed below. Keep consumer-facing PowerShell classes directly in the root module when relying on `using module`.

For distribution, you can build one ordered `.psm1` from source files, but preserve a reproducible build step and test the distributed output. Testing only the source layout can miss packaging errors. A small project may be easier to maintain with one readable root module than with a build system that exists only to concatenate ten tiny files.

## 7.5 Runtime command loading with Import-Module

`Import-Module` executes at runtime. Its path can be computed from configuration, `$PSScriptRoot`, or a parameter. This makes it appropriate for choosing optional command modules dynamically. If you call the resulting commands without naming custom classes in your script, you avoid many parse-time type requirements.

**Offline example 2 — inspect the modules already available in the session.**

```powershell
$utility = Get-Module -ListAvailable Microsoft.PowerShell.Utility |
    Sort-Object Version -Descending |
    Select-Object -First 1
Import-Module $utility.Path -ErrorAction Stop
Get-Command ConvertTo-Json | Select-Object Name, ModuleName
Get-Module Microsoft.PowerShell.Utility | Select-Object Name, Version
```

`-ListAvailable` searches discoverable module locations; `Get-Module` without it reports loaded modules. A command's `ModuleName` tells you where it came from. During troubleshooting, distinguish installed, discoverable, imported, and actually selected by command resolution.

If two modules export the same command name, import order and command precedence can affect the unqualified call. A module-qualified call such as `TeamCityAPI\Get-TeamCityBuildHistory` makes intent explicit. A project-specific noun prefix also reduces conflicts without forcing every caller to qualify every command.

`-Force` reloads module definitions in useful cases but does not make loaded PowerShell or .NET types disappear. `Remove-Module` removes the module's exported command surface; it is not a general type-unloading mechanism. Do not promise a class hot-reload workflow based on those commands.

## 7.6 Parse-time types with using module

PowerShell must know some types while parsing a file, especially base classes and typed members in class definitions. A runtime import later in that file cannot retroactively satisfy every parse-time requirement. `using module` supplies module type definitions at the language-loading boundary and must appear before other statements, including `param`.

**Offline example 3 — run a typed consumer in a fresh child process.**

```powershell
$lessonDirectory = Join-Path ([IO.Path]::GetTempPath()) ('TypedLesson-' + [guid]::NewGuid())
$null = New-Item -ItemType Directory -Path $lessonDirectory
$modelPath = Join-Path $lessonDirectory 'LessonModels.psm1'
$consumerPath = Join-Path $lessonDirectory 'Use-Models.ps1'
@'
class LessonBuild {
    [string]$Id
    LessonBuild([string]$id) { $this.Id = $id }
}
function New-LessonBuild { [LessonBuild]::new('factory-101') }
Export-ModuleMember -Function New-LessonBuild
'@ | Set-Content -LiteralPath $modelPath -Encoding utf8
@'
using module ./LessonModels.psm1
$build = [LessonBuild]::new('typed-101')
$build.Id
'@ | Set-Content -LiteralPath $consumerPath -Encoding utf8
try {
    & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File $consumerPath
    if ($LASTEXITCODE -ne 0) { throw 'Typed consumer failed.' }
}
finally {
    Remove-Item -LiteralPath $consumerPath, $modelPath
    Remove-Item -LiteralPath $lessonDirectory
}
```

This example uses `pwsh.exe` because the supplied learning environment is Windows. On Linux or macOS, use `Join-Path $PSHOME 'pwsh'`. The result is `typed-101`. The relative module path is resolved for the consumer file, and the class is declared directly in that module's root file.

`using module` requires a literal module specification, not an arbitrary runtime variable. This is a different job from dynamic imports. The [using statement reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_using) describes its placement and class-import behavior. Also distinguish it from `$using:variable`, which carries values into contexts such as remoting and parallel execution.

## 7.7 Factories reconcile dynamic loading with internal classes

A factory is an ordinary function that constructs an object. The caller imports the module dynamically and invokes `New-TeamCityClient`; the function references its own module's class. The caller can hold and invoke the returned object without declaring a `[TeamCityClient]` type literal in its own source.

This is especially useful when the class is an implementation detail. Public commands can accept the client as an object and validate the expected capability or type internally. That trades some static checking at the public signature for simpler dynamic loading. If callers truly need typed signatures, declare a stable shared models module and use a deliberate parse-time dependency.

Do not export a class with `Export-ModuleMember -Class`; that parameter does not exist. Classes are not exported using the same mechanism as functions. Also do not assume dot-sourcing a `Classes` directory from the root module reproduces the class visibility of declarations directly in the root module.

The earlier chat's sketch used that dot-sourced class layout. It can serve internal construction in some arrangements, but it is not a reliable public type-loading contract. This edition's example keeps its client class directly in the root module and uses a factory for dynamic consumers.

## 7.8 Discovery, autoloading, and version selection

PowerShell searches paths in `$env:PSModulePath` for modules. A conventional installed layout can include a module-name directory and version subdirectories. Explicit file-path imports are useful in a repository because they make the chosen source unambiguous and avoid accidentally importing a different installed copy.

Command discovery can autoload modules, but autoloading is a convenience rather than a reproducible dependency policy. In CI, import the intended manifest explicitly and record its version. `RequiredVersion` asks for an exact version; minimum and maximum version requirements express ranges. Confirm the selected module with `Get-Module` when diagnosing a mismatch.

Do not edit `$env:PSModulePath` globally just to make one project run. An entry script can import relative to `$PSScriptRoot`. A development session can use a temporary process-scoped path if necessary. Keep installation concerns separate from ordinary module use.

Versioning is about compatibility. A change from “returns no objects on no builds” to “returns one envelope object” can be breaking even if the command name is unchanged. A new optional parameter is usually less disruptive. Class property types, enum values, output ordering, and error behavior also deserve compatibility review.

## 7.9 Scope, caches, and multiple clients

Module-private `$script:` state can hold a cache, but then the cache belongs to the module session rather than one client. If the module supports multiple servers, include server identity in keys or move the cache into each client instance. The latter often makes ownership easier to understand.

Avoid storing the token in a global variable or exporting it. A client may need a token during its lifetime, but the public display and returned report data should not include it. A `SecureString` helps integrate with PowerShell's credential-taking APIs; it does not mean an authenticated process never handles usable secret material.

Cache lifetime also affects tests. A test that passes only when another test populated a module cache is order-dependent. Provide a deliberate reset mechanism for an internal test boundary, create a fresh client per test, or use fresh processes when type and module state make isolation difficult.

## 7.10 Dependencies should describe ownership, not recreate a shared global script

It is tempting to make every module import every other module so any function can call anything. That recreates the monolith's dependency graph in a more confusing form. The health module should not need the API module merely to receive observations, and the HTML module should not need the client merely to render results.

Use manifest dependencies for actual runtime or type requirements. Use the entry script to compose independent components. If two modules share a small plain-data contract, they may not need a module dependency at all. If they share a custom class, they need a deliberate shared type definition and compatible version policy.

A nested module is not simply another directory in the package. Manifest nesting has specific loading and export behavior. Avoid introducing it merely because the folder tree looks tidy. An explicit import at the composition root is often easier to understand for a small application.

**Offline example 4 — inspect an actual packaged manifest.**

```powershell
$path = './examples/ReferenceImplementation/PipelineHealth/PipelineHealth.psd1'
$data = Import-PowerShellDataFile -LiteralPath $path
$data.RootModule
$data.ModuleVersion
$data.FunctionsToExport
$module = Test-ModuleManifest -Path $path -ErrorAction Stop
$module.Name
```

The data-file reader inspects manifest data without treating it as an arbitrary ordinary script. `Test-ModuleManifest` then checks the actual module description. Both are useful, but importing and invoking the exported commands remains necessary to validate behavior.

Private helper names can collide inside a module too. If dot-sourced files define the same helper twice, the later definition can replace the earlier one. Deterministic loading makes that reproducible but does not make it correct. Keep one owner for each helper and use a small export list as a review aid.

Cross-module calls also need error and output discipline. A wrapper that forwards every warning, verbose line, and success object without a clear contract can accidentally publish internal diagnostics as data. Test the public interface from outside the module, not only private helpers through privileged test scope.

For class changes, restart the test process. For ordinary function changes, module reimport can be convenient during development, but final verification should still start clean. The difference between a productive editor workflow and a reproducible package workflow is worth preserving: fast iteration helps you build; clean execution proves what you built is self-contained.

## 7.11 Packaging verification and the TeamCity design

Validate a module from the artifact a user will extract: import every manifest, resolve exported commands, invoke one offline path, and ensure required files are present. Check that import itself does not make a network call. A valid manifest pointing at a missing private file is still an unusable package.

For this curriculum, the entry script imports `TeamCityAPI`, `PipelineHealth`, and `HTMLArtifact` from explicit paths. The API module's factory constructs its client. The health module receives plain observations. The HTML module receives analyzed rows and scan metadata. This keeps dynamic loading practical while avoiding custom type dependencies between all three modules.

You can later add a shared typed models assembly if several independent consumers need it. That would be a purposeful dependency with its own versioning and tests. It is not necessary merely to claim the application is object-oriented.

The engineering rule is to make loading reproducible in a clean process. A successful import in a long-running editor may depend on old types, old commands, or a changed search path. Fresh-session checks reveal whether the package actually contains everything its contract requires.

## 7.12 Follow one module import from disk to command invocation

An explicit manifest import starts by reading module metadata and locating the declared root module. The loader checks applicable requirements, creates or uses module session state, and evaluates the module's implementation. Export declarations then determine which commands become available to callers. These are several distinct steps, which explains why an apparently valid folder can still fail during import.

A manifest may exist while the root module is missing. The root module may load while a private helper file is absent. All files may exist while a custom type dependency is unavailable. Import may succeed while the exported function later fails because it still reads an undeclared caller variable. Packaging verification must exercise more than file presence.

After import, command resolution determines what an unqualified name invokes. A function defined in the caller's session can shadow a module command. Another module can export the same name. Use `Get-Command -All` when investigating ambiguity, and use a module-qualified name when the source is part of the required contract.

Inside the module, helper calls normally resolve in the module's own environment. That is why a Pester mock must target the module where the call occurs. It is also why moving a helper from a script to a module can expose hidden dependencies. The text has moved into a different ownership and lookup environment.

Finally, the exported function returns ordinary objects. Those objects may carry a custom type even when the caller never imported that type for use in a type literal. Calling a factory and holding its result is a runtime interaction. Declaring a new class that inherits that returned type is a parse-time interaction. Keep these use cases separate when deciding whether callers need `using module`.

## 7.13 Choose a development workflow that does not lie to you

During rapid function editing, reimporting a module can be convenient. During class or C# changes, a fresh process is the more reliable verification boundary. Do not spend hours trying to force a long-lived editor session to forget every old type. Separate the interactive editing experience from the clean-process checks that establish package correctness.

A practical workflow keeps source in one project directory, uses explicit path imports, and runs a small offline smoke command in a new process. The smoke command should create a client with a fake transport, retrieve an empty collection, analyze a small fixture, and render one document without networking. That checks the loading path and the main contracts without requiring a full live scan.

When a clean process fails but the editor succeeds, compare module paths, environment variables, loaded assemblies, and profile functions. Profiles can define helpers or aliases that your package never declared. `-NoProfile` removes that source of accidental support. A CI agent should not need your personal profile to understand the package.

When an installed copy succeeds but the repository copy fails, inspect which manifest was actually imported. Name-only imports can select a different version from the one you just edited. Recording the selected module path and version makes this visible. Do not infer success from the command name alone.

## 7.14 Treat exports and versions as promises to future callers

Exporting a helper makes it tempting for another script to depend on it. Once that happens, renaming or changing its output can become a breaking change. A narrow export list protects your ability to improve implementation details without coordinating every internal edit with consumers.

The reverse is also important: a private function should not be the only practical way to perform a legitimate public operation. If callers repeatedly reach into module internals to obtain normalized history, the public interface may be missing a useful capability. Add a documented command rather than relying on privileged invocation tricks in ordinary application code.

Version compatibility applies to data as well as functions. Changing a timestamp from local `DateTime` to `DateTimeOffset` improves meaning but can affect consumers. Grouping by ID instead of name can change row counts. Adding explicit partial-scan metadata is usually additive, while changing the top-level return shape can be breaking. Describe these changes in terms a caller can observe.

For the TeamCity migration, keeping modules independently understandable is more valuable than making them independently publishable immediately. They can share one repository and one release while retaining clear internal boundaries. Separate release pipelines are an operational choice, not a prerequisite for modular design.

As the project grows, add dependency declarations only when they represent real requirements. Avoid circular imports and broad wildcard exports. A module should have a comprehensible initialization path, a small public surface, and no surprise external effects on import. Those properties make dynamic loading useful without turning it into a source of hidden behavior.
