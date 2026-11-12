#requires -Version 7.4
[CmdletBinding()]
param(
    [string]$PesterManifest,
    [string]$AnalyzerManifest
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$generated = Join-Path $PSScriptRoot 'generated-examples'
$null = New-Item -ItemType Directory -Path $generated -Force
$chapters = @(Get-ChildItem -LiteralPath $root -File | Where-Object Name -match '^\d{2}-.+\.md$' | Sort-Object Name)
if ($chapters.Count -ne 12) { throw 'Exactly twelve numbered chapters are required.' }
$chapterStats = @()
$exampleResults = @()
$blockResults = @()
foreach ($chapter in $chapters) {
    $content = Get-Content -LiteralPath $chapter.FullName -Raw
    $wordCount = [regex]::Matches($content,'\S+').Count
    if ($wordCount -lt 3131) { throw "Chapter shorter than the two recovered opening messages combined: $($chapter.Name)" }
    $chapterStats += [pscustomobject]@{Chapter=$chapter.Name;Words=$wordCount;Bytes=$chapter.Length}
    $blocks = [regex]::Matches($content,'(?s)```powershell\r?\n(?<code>.*?)\r?\n```')
    $blockIndex = 0
    foreach ($block in $blocks) {
        $blockIndex++
        $tokens = $null
        $errorsFound = $null
        $null = [Management.Automation.Language.Parser]::ParseInput($block.Groups['code'].Value,[ref]$tokens,[ref]$errorsFound)
        $blockResults += [pscustomobject]@{Chapter=$chapter.Name;Block=$blockIndex;Errors=@($errorsFound | ForEach-Object Message)}
    }
    $examples = [regex]::Matches($content,'(?s)\*\*Offline example[^\r\n]*.*?```powershell\r?\n(?<code>.*?)\r?\n```')
    $exampleIndex = 0
    foreach ($example in $examples) {
        $exampleIndex++
        $name = '{0}-{1:00}.ps1' -f $chapter.Name.Substring(0,2),$exampleIndex
        $path = Join-Path $generated $name
        $preamble = @'
# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
'@
        ($preamble + "`n" + $example.Groups['code'].Value + "`n") | Set-Content -LiteralPath $path -Encoding utf8
        $executable = if ($IsWindows) { 'pwsh.exe' } else { 'pwsh' }
        $processInfo = [Diagnostics.ProcessStartInfo]::new((Join-Path $PSHOME $executable))
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        foreach ($argument in @('-NoLogo','-NoProfile','-NonInteractive','-File',$path)) { $processInfo.ArgumentList.Add($argument) }
        $process = [Diagnostics.Process]::Start($processInfo)
        $outputTask = $process.StandardOutput.ReadToEndAsync()
        $errorTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(30000)) { $process.Kill($true); throw "Example timed out: $name" }
        $outputText = $outputTask.GetAwaiter().GetResult()
        $errorText = $errorTask.GetAwaiter().GetResult()
        $exampleResults += [pscustomobject]@{Name=$name;ExitCode=$process.ExitCode;Output=$outputText.Trim();Error=$errorText.Trim()}
        $process.Dispose()
    }
}
$chapter10 = Get-Content -LiteralPath (Join-Path $root '10-testing-static-analysis-and-ci.md') -Raw
$chapter10Blocks = [regex]::Matches($chapter10,'(?s)```powershell\r?\n(?<code>.*?)\r?\n```')
$pairedDirectory = Join-Path $PSScriptRoot 'chapter10-paired-example'
$null = New-Item -ItemType Directory -Path $pairedDirectory -Force
$chapter10Blocks[1].Groups['code'].Value | Set-Content -LiteralPath (Join-Path $pairedDirectory 'Get-ObservedRedCount.ps1') -Encoding utf8
$chapter10Blocks[2].Groups['code'].Value | Set-Content -LiteralPath (Join-Path $pairedDirectory 'Get-ObservedRedCount.Tests.ps1') -Encoding utf8
$characterization = @(& (Join-Path $PSScriptRoot 'Test-OriginalBehavior.ps1'))
if ($characterization.Count -ne 5) { throw 'Expected five original-source characterization scenarios.' }
$manifestResults = @(Get-ChildItem -LiteralPath (Join-Path $root 'examples/ReferenceImplementation') -Filter '*.psd1' -Recurse | ForEach-Object {
    $module = Test-ModuleManifest -Path $_.FullName -ErrorAction Stop
    [pscustomobject]@{Name=$module.Name;Version=[string]$module.Version}
})
$fileParseResults = @(Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object Extension -in @('.ps1','.psm1','.psd1') | ForEach-Object {
    $tokens = $null
    $errorsFound = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$tokens,[ref]$errorsFound)
    [pscustomobject]@{File=$_.FullName.Substring($root.Length+1);Errors=@($errorsFound | ForEach-Object Message)}
})
$pesterSummary = $null
if ($PesterManifest) {
    Import-Module $PesterManifest -Force -ErrorAction Stop
    $configuration = New-PesterConfiguration
    $configuration.Run.Path = @((Join-Path $PSScriptRoot 'ReferenceImplementation.Tests.ps1'), $pairedDirectory)
    $configuration.Run.PassThru = $true
    # No registry operations are under test; do not allocate Pester's optional registry drive.
    $configuration.TestRegistry.Enabled = $false
    $configuration.Output.Verbosity = 'Normal'
    $testResult = Invoke-Pester -Configuration $configuration
    $pesterSummary = [pscustomobject]@{Version=[string](Get-Module Pester).Version;Total=$testResult.TotalCount;Passed=$testResult.PassedCount;Failed=$testResult.FailedCount;Skipped=$testResult.SkippedCount}
}
$analyzerFindings = @()
if ($AnalyzerManifest) {
    Import-Module $AnalyzerManifest -Force -ErrorAction Stop
    $analyzerFindings = @(Invoke-ScriptAnalyzer -Path (Join-Path $root 'examples/ReferenceImplementation') -Recurse | Select-Object RuleName,@{Name='Severity';Expression={[string]$_.Severity}},ScriptName,Line,Message)
}
$result = [pscustomobject]@{
    Runtime = [string]$PSVersionTable.PSVersion
    Edition = $PSVersionTable.PSEdition
    Chapters = $chapterStats
    Blocks = $blockResults
    Examples = $exampleResults
    OriginalCharacterization = $characterization
    Manifests = $manifestResults
    FileParsing = $fileParseResults
    Pester = $pesterSummary
    AnalyzerVersion = if ($AnalyzerManifest) { [string](Get-Module PSScriptAnalyzer).Version } else { $null }
    AnalyzerFindings = $analyzerFindings
}
$result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.json') -Encoding utf8
$failedExamples = @($exampleResults | Where-Object ExitCode -ne 0)
$parseFailures = @($blockResults | Where-Object { $_.Errors.Count -gt 0 }) + @($fileParseResults | Where-Object { $_.Errors.Count -gt 0 })
$lintErrors = @($analyzerFindings | Where-Object Severity -eq Error)
if ($failedExamples.Count -or $parseFailures.Count -or $lintErrors.Count -or ($pesterSummary -and $pesterSummary.Failed)) {
    $failedExamples | Select-Object Name,Error | Format-List | Out-Host
    $parseFailures | Format-List | Out-Host
    throw 'Curriculum verification failed; inspect verification/results.json.'
}
[pscustomobject]@{Chapters=$chapters.Count;Examples=$exampleResults.Count;PowerShellBlocks=$blockResults.Count;OriginalCases=$characterization.Count;PesterPassed=if($pesterSummary){$pesterSummary.Passed}else{0};LintErrors=$lintErrors.Count}
