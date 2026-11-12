# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$path = Join-Path (Get-Location) 'reference/New-RedTeamCityPipelineHtmlReport.txt'
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $path, [ref]$tokens, [ref]$parseErrors
)
if ($parseErrors.Count) { throw 'Source contains parse errors.' }
$functions = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [System.Management.Automation.Language.FunctionDefinitionAst]
})
$functions | Select-Object Name, @{ Name = 'StartLine'; Expression = { $_.Extent.StartLineNumber } }

