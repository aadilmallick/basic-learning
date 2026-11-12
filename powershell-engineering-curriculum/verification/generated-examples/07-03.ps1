# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
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

