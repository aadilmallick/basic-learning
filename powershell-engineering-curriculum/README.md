# PowerShell Engineering Curriculum — expanded edition

Twelve substantial chapters for an intermediate PowerShell user learning to design modular applications with advanced functions, OOP, C#, and .NET. Revised November 12, 2026. The material follows a first-principles sequence: motivation, mental model, small examples, explanation, realistic application, tradeoffs, and pitfalls. There are no quizzes or active-recall sections.

Each numbered chapter exceeds the combined 3,131-word length of the two recovered opening assistant messages. The [verification report](verification/VERIFICATION.md) records exact sizes and checks. The earlier brief chapters were replaced, retaining their twelve-stage subject order and filenames.

## Chapters

| Stage | Chapter |
|---|---|
| 1 | [PowerShell execution model](01-powershell-execution-model.md) |
| 2 | [Advanced functions and CmdletBinding](02-advanced-functions-and-cmdletbinding.md) |
| 3 | [Errors, reliability, and diagnostics](03-errors-reliability-and-diagnostics.md) |
| 4 | [Object-oriented PowerShell foundations](04-object-oriented-powershell-foundations.md) |
| 5 | [Advanced OOP and composition](05-advanced-oop-and-composition.md) |
| 6 | [PowerShell and C# interoperability](06-powershell-and-csharp-interoperability.md) |
| 7 | [Modules, manifests, and loading](07-modules-manifests-and-loading.md) |
| 8 | [Software design and dependency injection](08-software-design-and-dependency-injection.md) |
| 9 | [REST API engineering for TeamCity](09-rest-api-engineering-for-teamcity.md) |
| 10 | [Testing, static analysis, and CI](10-testing-static-analysis-and-ci.md) |
| 11 | [Reading the actual uploaded TeamCity report](11-case-study-reading-the-existing-teamcity-report.md) |
| 12 | [Guided refactoring and runnable architecture](12-guided-refactoring-and-reference-architecture.md) |

## Use the examples

Use PowerShell 7.4 or later. The actual validation runtime and tool versions are recorded in the report; PowerShell 7.4 and Windows PowerShell 5.1 were not separately executed for this edition. Class and C# examples should run in fresh processes when their definitions change. Examples are explained beside the relevant concepts rather than presented as unexplained code dumps.

Blocks marked **Offline example** are complete and need no server or credentials. Their extracted `.ps1` versions are in [verification/generated-examples](verification/generated-examples). They automatically select the curriculum root as their working directory. Other blocks are explicitly identified as fragments, setup patterns, paired files, manifests, or live-use patterns. Do not run all chapter blocks as one concatenated script.

From this directory, run the complete modular demonstration:

```powershell
pwsh -NoProfile -File ./examples/ReferenceImplementation/New-TeamCityHealthReport.ps1 -Offline
```

It creates [Red.html](examples/ReferenceImplementation/output/Red.html), [Summary.html](examples/ReferenceImplementation/output/Summary.html), and [Projects.html](examples/ReferenceImplementation/output/Projects.html). Example outputs are included. The fixture deliberately contains one unavailable inspection so the reports demonstrate partial-scan accounting.

For a preview without writing artifacts:

```powershell
pwsh -NoProfile -File ./examples/ReferenceImplementation/New-TeamCityHealthReport.ps1 -Offline -WhatIf
```

The modules are ordinary local files with explicit manifests. Import does not contact TeamCity. The live adapter requires an explicit server and token, and the chapters explain deployment-specific validation rather than claiming a tested production replacement.

## Source-grounded final chapters

The preserved [New-RedTeamCityPipelineHtmlReport.txt](reference/New-RedTeamCityPipelineHtmlReport.txt) is the actual uploaded file. Stage 11 references its measured line numbers and walks through every function and the main workflow. The [original-behavior runner](verification/Test-OriginalBehavior.ps1) characterizes selected functions without executing the original startup, HTTP calls, or report writes.

Stage 12 explains the complete [teaching implementation](examples/ReferenceImplementation), its OOP client, dynamic module imports, pure analyzer, renderer, fixtures, and tests. A compatibility table identifies preserved rules and deliberate changes. The new layout and command-line interface are simplified; it is not a drop-in replica of every legacy field or HTML detail.

## Reproduce verification

Run language examples, manifest checks, source characterization, and parsing without external test dependencies:

```powershell
pwsh -NoProfile -File ./verification/Invoke-CurriculumVerification.ps1
```

To include Pester and PSScriptAnalyzer, supply paths to your approved installed versions:

```powershell
./verification/Invoke-CurriculumVerification.ps1 -PesterManifest /path/to/Pester.psd1 -AnalyzerManifest /path/to/PSScriptAnalyzer.psd1
```

Those paths are argument examples; replace them with actual manifest paths. The report distinguishes executed checks from external assumptions. Tool dependencies are not bundled into the curriculum ZIP. Technical references appear in the relevant chapters and use Microsoft, JetBrains, and Pester documentation.
