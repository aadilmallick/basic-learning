#requires -Version 7.4
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$source = Join-Path (Split-Path $PSScriptRoot -Parent) 'reference/New-RedTeamCityPipelineHtmlReport.txt'
$tokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($source,[ref]$tokens,[ref]$parseErrors)
if ($parseErrors.Count) { throw 'Original source failed parsing.' }
$definitions = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst]
} | ForEach-Object { $_.Extent.Text }) -join "`n"
$original = New-Module -Name OriginalCharacterization -ArgumentList $definitions -ScriptBlock {
    param($definitionText)
    . ([scriptblock]::Create($definitionText))
    function Get-TopLevelProjectName { param($ProjectId,$FallbackProjectName) 'Top' }
    function Get-RecentFinishedBuilds { param($BuildTypeId) $script:history }
    Export-ModuleMember -Function Get-PipelineInfo
}
try {
    & $original {
        $buildType = [pscustomobject]@{id='A';name='Pipeline';projectId='P';projectName='Project';webUrl='https://ci.example.com/a'}
        $cases = @(
            @{Name='No builds'; Statuses=@(); Health='OTHER'; Count=0; Uncertain=$false},
            @{Name='Latest green'; Statuses=@('SUCCESS','FAILURE'); Health='GREEN'; Count=0; Uncertain=$false},
            @{Name='Known boundary'; Statuses=@('FAILURE','ERROR','SUCCESS'); Health='RED'; Count=2; Uncertain=$false},
            @{Name='All red'; Statuses=@('FAILURE','FAILURE'); Health='RED'; Count=2; Uncertain=$true},
            @{Name='Unknown boundary'; Statuses=@('FAILURE','UNKNOWN','FAILURE'); Health='RED'; Count=1; Uncertain=$false}
        )
        foreach ($case in $cases) {
            $script:history = @(for ($index=0; $index -lt $case.Statuses.Count; $index++) {
                [pscustomobject]@{id=[string](100-$index);number=[string](100-$index);status=$case.Statuses[$index];finishDate=('202611{0:00}T140000+0000' -f (12-$index));webUrl='https://ci.example.com/build'}
            })
            $result = Get-PipelineInfo -BuildType $buildType
            if ($result.HealthStatus -ne $case.Health -or $result.RedBuildCount -ne $case.Count -or
                ($result.BecameRedText -like 'At least since*') -ne $case.Uncertain) {
                throw "Original characterization failed: $($case.Name)"
            }
            [pscustomobject]@{Case=$case.Name;Health=$result.HealthStatus;RedCount=$result.RedBuildCount;Passed=$true}
        }
    }
}
finally { Remove-Module $original -ErrorAction SilentlyContinue }
