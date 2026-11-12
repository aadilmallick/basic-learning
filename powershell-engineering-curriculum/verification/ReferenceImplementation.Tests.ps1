BeforeAll {
    $script:curriculumRoot = Split-Path $PSScriptRoot -Parent
    $script:implementation = Join-Path $script:curriculumRoot 'examples/ReferenceImplementation'
    foreach ($name in @('TeamCityAPI','PipelineHealth','HTMLArtifact')) {
        Import-Module (Join-Path $script:implementation "$name/$name.psd1") -Force
    }
    function New-Token { ConvertTo-SecureString 'fixture-token' -AsPlainText -Force }
    function New-Observation {
        param([string]$Status, [int]$Day = 12)
        [pscustomobject]@{ Status = $Status; FinishedAt = [DateTimeOffset]::new(2026,11,$Day,14,0,0,[TimeSpan]::Zero) }
    }
    function New-TestScan {
        $row = [pscustomobject]@{
            PipelineId = 'A'; PipelineName = '<API> & tests'; PipelineUrl = 'https://ci.example.com/a?x=1&y=2'
            ProjectId = 'P'; ProjectName = 'Project'; TopLevelProjectId = 'T'; TopLevelProjectName = 'Top'
            Health = 'RED'; LatestStatus = 'FAILURE'; LatestAt = [DateTimeOffset]::Parse('2026-11-12T14:00:00Z')
            OldestObservedRedAt = [DateTimeOffset]::Parse('2026-11-10T14:00:00Z')
            BoundaryObserved = $false; ObservedRedCount = 2
        }
        [pscustomobject]@{
            GeneratedAt = [DateTimeOffset]::Parse('2026-11-12T14:00:00Z'); Server = 'https://ci.example.com/'
            Scope = 'Fixture'; Listed = 2; Excluded = 0; Eligible = 2; Rows = @($row)
            Failures = @([pscustomobject]@{ Id = 'Unavailable'; Reason = 'Unavailable' }); GroupingFallbacks = 0
        }
    }
}

Describe 'Pipeline health semantics' {
    It 'classifies <Status> as <Expected>' -TestCases @(
        @{ Status='SUCCESS'; Expected='GREEN' }, @{ Status='FAILURE'; Expected='RED' },
        @{ Status='ERROR'; Expected='RED' }, @{ Status='UNKNOWN'; Expected='OTHER' },
        @{ Status='failure'; Expected='RED' }
    ) {
        param($Status,$Expected)
        (Get-PipelineHealth -NewestFirstBuilds @((New-Observation $Status))).Health | Should -Be $Expected
    }
    It 'counts only the current red prefix' {
        $result = Get-PipelineHealth -NewestFirstBuilds @(
            (New-Observation FAILURE 12), (New-Observation ERROR 11),
            (New-Observation SUCCESS 10), (New-Observation FAILURE 9)
        )
        $result.ObservedRedCount | Should -Be 2
        $result.BoundaryObserved | Should -BeTrue
        $result.OldestObservedRedAt.Day | Should -Be 11
    }
    It 'retains uncertainty for all-red history' {
        $result = Get-PipelineHealth -NewestFirstBuilds @((New-Observation FAILURE), (New-Observation FAILURE 11))
        $result.BoundaryObserved | Should -BeFalse
        $result.ObservedRedCount | Should -Be 2
    }
    It 'preserves the original unknown-status boundary rule' {
        $result = Get-PipelineHealth -NewestFirstBuilds @((New-Observation FAILURE), (New-Observation UNKNOWN 11), (New-Observation FAILURE 10))
        $result.ObservedRedCount | Should -Be 1
        $result.BoundaryObserved | Should -BeTrue
    }
    It 'represents no builds as OTHER with no invented timestamp' {
        $result = Get-PipelineHealth -NewestFirstBuilds @()
        $result.Health | Should -Be OTHER
        $result.LatestStatus | Should -Be NO_BUILDS
        $result.LatestAt | Should -BeNullOrEmpty
    }
    It 'does not mutate input order or status' {
        $builds = @((New-Observation failure), (New-Observation SUCCESS 11))
        $null = Get-PipelineHealth -NewestFirstBuilds $builds
        $builds[0].Status | Should -BeExactly 'failure'
    }
    It 'rejects a missing usable status' {
        { Get-PipelineHealth -NewestFirstBuilds @([pscustomobject]@{Status='';FinishedAt=$null}) } | Should -Throw
    }
    It 'summarizes empty input as zero' {
        (Get-HealthSummary -Rows @()).Total | Should -Be 0
    }
    It 'rejects an unknown internal health classification' {
        { Get-HealthSummary -Rows @([pscustomobject]@{Health='INVALID'}) } | Should -Throw
    }
}

Describe 'TeamCity client boundaries' {
    It 'preserves a context path for <Server>' -TestCases @(
        @{Server='https://ci.example.com/teamcity/'}, @{Server='https://ci.example.com/teamcity/app/rest/'}
    ) {
        param($Server)
        $client = New-TeamCityClient -Server $Server -Token (New-Token)
        $client.RestRoot.AbsolutePath | Should -Be '/teamcity/app/rest/'
    }
    It 'rejects HTTP' {
        { New-TeamCityClient -Server 'http://ci.example.com/' -Token (New-Token) } | Should -Throw
    }
    It 'rejects a server query' {
        { New-TeamCityClient -Server 'https://ci.example.com/?token=example' -Token (New-Token) } | Should -Throw
    }
    It 'follows a continuation after a short page and deduplicates IDs' {
        $state = @{ Calls = 0 }
        $transport = {
            param($uri,$token)
            $state.Calls++
            if ($state.Calls -eq 1) {
                return [pscustomobject]@{ buildType=@([pscustomobject]@{id='A'}); nextHref='/app/rest/buildTypes?page=2' }
            }
            [pscustomobject]@{ buildType=@([pscustomobject]@{id='A'},[pscustomobject]@{id='B'}); nextHref='' }
        }.GetNewClosure()
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        @(Get-TeamCityBuildType -Client $client -PageSize 100).Count | Should -Be 2
        $state.Calls | Should -Be 2
    }
    It 'rejects a foreign continuation before transport receives it' {
        $state = @{Calls=0}
        $transport = {
            param($uri,$token)
            $state.Calls++
            [pscustomobject]@{buildType=@();nextHref='https://other.example.com/app/rest/buildTypes'}
        }.GetNewClosure()
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        { @(Get-TeamCityBuildType -Client $client) } | Should -Throw '*outside*'
        $state.Calls | Should -Be 1
    }
    It 'detects a repeated continuation' {
        $transport = { param($uri,$token) [pscustomobject]@{buildType=@();nextHref='/app/rest/buildTypes?loop=1'} }
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        { @(Get-TeamCityBuildType -Client $client) } | Should -Throw '*Pagination*'
    }
    It 'rejects a missing collection' {
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport { param($uri,$token) [pscustomobject]@{message='wrong shape'} }
        { @(Get-TeamCityBuildType -Client $client) } | Should -Throw '*collection*'
    }
    It 'rejects locator punctuation in the conservative ID contract' {
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token)
        { @(Get-TeamCityBuildHistory -Client $client -BuildTypeId 'A),count:999') } | Should -Throw '*simple external IDs*'
    }
    It 'bounds history and normalizes timestamps' {
        $transport = {
            param($uri,$token)
            [pscustomobject]@{build=@(
                [pscustomobject]@{id='1';status='failure';finishDate='20261112T090000-0500'},
                [pscustomobject]@{id='2';status='SUCCESS';finishDate='invalid'}
            );nextHref='https://other.example.com/app/rest/builds'}
        }
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        $builds = @(Get-TeamCityBuildHistory -Client $client -BuildTypeId A -Limit 1)
        $builds.Count | Should -Be 1
        $builds[0].Status | Should -BeExactly FAILURE
        $builds[0].FinishedAt.UtcDateTime.Hour | Should -Be 14
    }
    It 'leaves an invalid optional timestamp unknown' {
        $transport = { param($uri,$token) [pscustomobject]@{build=@([pscustomobject]@{id='1';status='SUCCESS';finishDate='invalid'});nextHref=''} }
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        @(Get-TeamCityBuildHistory -Client $client -BuildTypeId A)[0].FinishedAt | Should -BeNullOrEmpty
    }
    It 'caches projects per client' {
        $state = @{Calls=0}
        $transport = {
            param($uri,$token)
            $state.Calls++
            [pscustomobject]@{id='P';name='Project';parentProject=[pscustomobject]@{id='_Root';name='Root'}}
        }.GetNewClosure()
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        $null = Resolve-TeamCityTopProject -Client $client -ProjectId P
        $null = Resolve-TeamCityTopProject -Client $client -ProjectId P
        $state.Calls | Should -Be 1
    }
    It 'detects a hierarchy cycle' {
        $transport = { param($uri,$token) [pscustomobject]@{id='P';name='Project';parentProject=[pscustomobject]@{id='P';name='Project'}} }
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token) -Transport $transport
        { Resolve-TeamCityTopProject -Client $client -ProjectId P } | Should -Throw '*Cycle*'
    }
    It 'supports a Pester mock at the default HTTP boundary' {
        Mock Invoke-RestMethod -ModuleName TeamCityAPI { [pscustomobject]@{buildType=@();nextHref=''} }
        $client = New-TeamCityClient -Server 'https://ci.example.com/' -Token (New-Token)
        @(Get-TeamCityBuildType -Client $client).Count | Should -Be 0
        Should -Invoke Invoke-RestMethod -ModuleName TeamCityAPI -Times 1 -Exactly
    }
}

Describe 'Artifacts and application behavior' {
    It 'renders <View> with persisted coverage' -TestCases @(@{View='Red'},@{View='Summary'},@{View='Projects'}) {
        param($View)
        $html = ConvertTo-PipelineReportHtml -Scan (New-TestScan) -View $View
        $html | Should -Match 'failed inspections: 1'
        $html | Should -Match '<!doctype html>'
    }
    It 'encodes text and query ampersands' {
        $html = ConvertTo-PipelineReportHtml -Scan (New-TestScan) -View Red
        $html | Should -Match '&lt;API&gt; &amp; tests'
        $html | Should -Match 'x=1&amp;y=2'
        $html | Should -Match 'At least since'
    }
    It 'does not create a javascript anchor' {
        $scan = New-TestScan
        $scan.Rows[0].PipelineUrl = 'javascript:alert(1)'
        (ConvertTo-PipelineReportHtml -Scan $scan -View Red) | Should -Not -Match 'href="javascript:'
    }
    It 'keeps duplicate project names separate by ID' {
        $scan = New-TestScan
        $copy = $scan.Rows[0].PSObject.Copy()
        $copy.ProjectId = 'p'
        $scan.Rows = @($scan.Rows[0],$copy)
        $html = ConvertTo-PipelineReportHtml -Scan $scan -View Summary
        $html | Should -MatchExactly 'Project \(P\)'
        $html | Should -MatchExactly 'Project \(p\)'
    }
    It 'handles empty reports' {
        $scan = New-TestScan
        $scan.Rows = @()
        (ConvertTo-PipelineReportHtml -Scan $scan -View Summary) | Should -Match 'No inspected pipelines'
    }
    It 'previews a writer without a file effect' {
        $path = Join-Path $TestDrive 'preview.html'
        Export-HtmlArtifact -LiteralPath $path -Html '<p>Example</p>' -WhatIf
        Test-Path -LiteralPath $path | Should -BeFalse
    }
    It 'writes and replaces UTF-8 content without temporary leftovers' {
        $path = Join-Path $TestDrive 'actual.html'
        $null = Export-HtmlArtifact -LiteralPath $path -Html '<p>First</p>' -Confirm:$false
        $null = Export-HtmlArtifact -LiteralPath $path -Html '<p>Second & é</p>' -Confirm:$false
        Get-Content -LiteralPath $path -Raw | Should -BeExactly '<p>Second & é</p>'
        @(Get-ChildItem -LiteralPath $TestDrive -Filter '*.tmp').Count | Should -Be 0
    }
    It 'runs the complete offline workflow with correct coverage' {
        $result = & (Join-Path $script:implementation 'New-TeamCityHealthReport.ps1') -Offline -OutputDirectory (Join-Path $TestDrive 'reports')
        $result.Scan.Listed | Should -Be 6
        $result.Scan.Rows.Count | Should -Be 5
        $result.Scan.Failures.Count | Should -Be 1
        $result.Scan.IsComplete | Should -BeFalse
        $result.WrittenPaths.Count | Should -Be 3
        $summary = Get-HealthSummary -Rows $result.Scan.Rows
        $summary.Red | Should -Be 2
        $summary.Green | Should -Be 1
        $summary.Other | Should -Be 2
    }
    It 'applies immediate-name wildcard exclusions' {
        $result = & (Join-Path $script:implementation 'New-TeamCityHealthReport.ps1') -Offline -ExcludeProjectName 'Front*' -OutputDirectory (Join-Path $TestDrive 'excluded')
        $result.Scan.Excluded | Should -Be 3
        $result.Scan.Eligible | Should -Be 3
    }
    It 'does not create an application directory under WhatIf' {
        $path = Join-Path $TestDrive 'application-preview'
        $result = & (Join-Path $script:implementation 'New-TeamCityHealthReport.ps1') -Offline -OutputDirectory $path -WhatIf
        Test-Path -LiteralPath $path | Should -BeFalse
        $result.WrittenPaths.Count | Should -Be 0
    }
}
