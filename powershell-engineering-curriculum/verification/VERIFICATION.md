# Verification record — November 12, 2026

The expanded curriculum contains twelve numbered chapters totaling **38,756 words**, compared with **6,607 words** in the previous ZIP's chapters: approximately **5.87 times** the original total. Each chapter exceeds the **3,131 words** in the two recovered opening assistant messages combined (2,210 plus 921), using the same whitespace-token counting method for comparison. Counts include prose, headings, and code; they are an extent measure, not a substitute for instructional quality.

## Chapter sizes

| Stage | Words | UTF-8 bytes |
|---|---:|---:|
| 1 | 3,246 | 23,136 |
| 2 | 3,235 | 24,656 |
| 3 | 3,201 | 23,356 |
| 4 | 3,228 | 23,399 |
| 5 | 3,233 | 23,298 |
| 6 | 3,234 | 23,770 |
| 7 | 3,224 | 23,193 |
| 8 | 3,251 | 23,273 |
| 9 | 3,186 | 23,623 |
| 10 | 3,208 | 23,162 |
| 11 | 3,240 | 22,903 |
| 12 | 3,270 | 23,984 |

The original size records are in [original-chapter-sizes.json](original-chapter-sizes.json). The revised records and executable results are in [results.json](results.json).

## Executed checks

- **65 marked offline examples** extracted from the chapters and executed individually in fresh, noninteractive PowerShell processes: all completed successfully. Their executable files are included in [generated-examples](generated-examples).
- **73 PowerShell chapter code blocks** parsed with no syntax errors. Some are expressly labeled fragments, manifests, setup patterns, or live-use patterns; parsing is not claimed as execution for those blocks.
- **77 packaged PowerShell files** parsed with no syntax errors, including modules, manifests, verification scripts, extracted examples, and the paired Pester lesson.
- **42 Pester tests** passed, with zero failures and zero skips: 39 focused implementation tests plus three tests from the actual paired-file chapter 10 example.
- **Five original-source characterization scenarios** passed: no builds, latest green, a known red boundary, all-red history, and an unknown-status boundary.
- **Three module manifests** validated successfully.
- **PSScriptAnalyzer:** zero remaining findings against the reference implementation under the tool's default rules. Narrow documented suppressions cover in-memory factory functions and the fixed offline placeholder token. The optional Pester registry drive is disabled because no registry operations are under test.
- The offline application generated all three HTML views with the expected six listed, five inspected, and one failed configuration. Preview checks confirmed no directory or file was created under `-WhatIf`.

The focused tests cover red-prefix semantics, uncertain boundaries, no-build classification, input preservation, invalid statuses, summary invariants, context paths, short-page continuations, deduplication, repeated and foreign continuations, ID validation, timestamp normalization, missing collections, project caching and cycles, HTTP mocking, encoding, unsafe link schemes, project identity, empty reports, UTF-8 replacement, wildcard exclusions, and partial-scan accounting.

## Runtime and tools

| Component | Executed version |
|---|---|
| PowerShell | 7.6.9, Core edition |
| .NET | 10.0.14 |
| Operating system | Windows, build 22631 |
| Pester | 5.7.1 |
| PSScriptAnalyzer | 1.24.0 |

The material is written for PowerShell 7.4+ using APIs intended for that baseline. PowerShell 7.4, Windows PowerShell 5.1, Linux, and macOS were not independently executed for this edition. Stage 7's child-process demonstration explicitly explains its Windows executable name and the alternative on other platforms.

## Source provenance and limits

The actual uploaded [New-RedTeamCityPipelineHtmlReport.txt](../reference/New-RedTeamCityPipelineHtmlReport.txt) was preserved. SHA-256: `4B2B3C42471D3AAFA5D6D4B96E4D6CA1436334929EA44E85FADBA32E10FF7AB2`. It has 913 lines when read by `Get-Content`. Stage 11's function inventory and line references were checked against that file. Characterization evaluates only its extracted function definitions and replaces external lookups; the original startup and main workflow were never executed.

The initial benchmark was recovered from the referenced “PowerShell OOP Learning Path” chat. It includes both opening assistant messages, so the minimum is stricter than comparing only the first long message. The curriculum follows its stage ordering and substantially expands the old chapter files, rather than claiming the original archive was already sufficiently detailed.

No live TeamCity requests were made. Offline fixtures cannot establish a particular deployment's permissions, ordering, branch selection, retention, lookup limits, or version-specific response shape. The live adapter is a teaching implementation with an explicit limited ID grammar and no production retry/rate-limit framework. Stage 12 documents the simplified layout, changed timezone presentation, added coverage reporting, and other differences from the legacy interface.

Official Microsoft, JetBrains, and Pester references were consulted for version-sensitive language and API rules. The chapters link those references near the relevant discussion. No claim of universal defect-freedom or production drop-in compatibility is made.

## Reproduction and packaging

Run [Invoke-CurriculumVerification.ps1](Invoke-CurriculumVerification.ps1) from any working directory. Supply installed Pester and analyzer manifest paths to include those optional checks. It returns a summary and refreshes `results.json`; without tool paths it runs the dependency-free checks and reports that no Pester tests were requested.

The ZIP contains this curriculum directory, the twelve individual Markdown chapters, preserved source, runnable modules, fixtures, sample HTML, tests, and verification evidence. External tool packages are excluded. `SHA256SUMS.txt` records file checksums. ZIP entry contents are compared with their source files during packaging; the ZIP's own hash is supplied separately beside the archive.
