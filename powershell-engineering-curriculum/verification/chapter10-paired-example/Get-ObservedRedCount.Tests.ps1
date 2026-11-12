BeforeAll {
    . (Join-Path $PSScriptRoot 'Get-ObservedRedCount.ps1')
}
Describe 'Get-ObservedRedCount' {
    It 'stops at the first non-red build' {
        $builds = @(
            [pscustomobject]@{ Status = 'FAILURE' }
            [pscustomobject]@{ Status = 'ERROR' }
            [pscustomobject]@{ Status = 'SUCCESS' }
            [pscustomobject]@{ Status = 'FAILURE' }
        )
        Get-ObservedRedCount -Builds $builds | Should -Be 2
    }
    It 'returns zero for no observations' {
        Get-ObservedRedCount -Builds @() | Should -Be 0
    }
    It 'returns zero when the latest build is green' {
        Get-ObservedRedCount -Builds @(
            [pscustomobject]@{ Status = 'SUCCESS' }
        ) | Should -Be 0
    }
}
