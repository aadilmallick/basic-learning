# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
function Export-TeamCityText {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text
    )
    $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $LiteralPath
    )
    if ($PSCmdlet.ShouldProcess($resolved, 'Write TeamCity text artifact')) {
        [IO.File]::WriteAllText($resolved, $Text, [Text.UTF8Encoding]::new($false))
        Get-Item -LiteralPath $resolved
    }
}
Export-TeamCityText -LiteralPath './preview-only.html' -Text '<p>Example</p>' -WhatIf

