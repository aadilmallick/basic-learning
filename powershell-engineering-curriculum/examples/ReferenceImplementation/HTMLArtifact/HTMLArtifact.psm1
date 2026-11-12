Set-StrictMode -Version Latest

function ConvertTo-HtmlText {
    param([AllowNull()][object]$Value)
    [Net.WebUtility]::HtmlEncode([string]$Value)
}

function ConvertTo-SafeLink {
    param([string]$Url, [string]$Label)
    $uri = $null
    $text = ConvertTo-HtmlText $Label
    if ([uri]::TryCreate($Url, [UriKind]::Absolute, [ref]$uri) -and
        $uri.Scheme -eq 'https' -and -not $uri.UserInfo) {
        return '<a href="{0}">{1}</a>' -f (ConvertTo-HtmlText $uri.AbsoluteUri), $text
    }
    $text
}

function Format-ReportInstant {
    param([AllowNull()][object]$Instant)
    if ($null -eq $Instant) { return 'Unknown' }
    ([DateTimeOffset]$Instant).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
}

function ConvertTo-HealthChartHtml {
    param([object[]]$Rows)
    $total = $Rows.Count
    $green = @($Rows | Where-Object Health -eq GREEN).Count
    $red = @($Rows | Where-Object Health -eq RED).Count
    $other = $total - $green - $red
    if ($total -eq 0) { return '<p>No inspected pipelines.</p>' }
    $culture = [Globalization.CultureInfo]::InvariantCulture
    $greenEnd = (360.0 * $green / $total).ToString('0.###', $culture)
    $redEnd = (360.0 * ($green + $red) / $total).ToString('0.###', $culture)
    '<div class="pie" aria-hidden="true" style="background:conic-gradient(#2f8f5b 0deg {0}deg,#c5282f {0}deg {1}deg,#7b8794 {1}deg 360deg)"></div><p>Green: {2}; Red: {3}; Other/no builds: {4}; Inspected: {5}.</p>' -f $greenEnd,$redEnd,$green,$red,$other,$total
}

function ConvertTo-PipelineReportHtml {
    <#
    .SYNOPSIS
    Renders one of three report views from an already completed scan snapshot.
    .DESCRIPTION
    Performs no network or filesystem operations. Counts describe inspected rows;
    scan failures and grouping fallbacks remain visible in every view. Dates use UTC.
    .PARAMETER Scan
    An envelope with GeneratedAt, Server, Scope, Listed, Excluded, Eligible, Rows,
    Failures, and GroupingFallbacks. See the entry script for the row schema.
    .PARAMETER View
    Red lists current red streaks; Summary aggregates immediate projects; Projects
    renders charts grouped by top-level project identity.
    .OUTPUTS
    System.String
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][psobject]$Scan,
        [ValidateSet('Red','Summary','Projects')][string]$View = 'Summary'
    )
    $titles = @{ Red = 'Red pipelines'; Summary = 'Pipeline health'; Projects = 'Top-level project health' }
    $builder = [Text.StringBuilder]::new()
    [void]$builder.AppendLine('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">')
    [void]$builder.AppendLine('<title>{0}</title>' -f $titles[$View])
    [void]$builder.AppendLine('<style>body{font:16px Segoe UI,sans-serif;max-width:1100px;margin:2rem auto;padding:0 1rem;color:#18212f}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ccd3db;text-align:left;padding:.6rem}caption{text-align:left;font-weight:bold;margin:1rem 0}.notice{padding:1rem;background:#fff0cf}.pie{width:120px;height:120px;border-radius:50%}section{margin:2rem 0}a{color:#075e80}</style></head><body>')
    [void]$builder.AppendLine('<h1>{0}</h1>' -f $titles[$View])
    [void]$builder.AppendLine(('<p>Generated {0}. Source: {1}. Scope: {2}.</p>' -f
        (ConvertTo-HtmlText (Format-ReportInstant $Scan.GeneratedAt)),
        (ConvertTo-HtmlText $Scan.Server), (ConvertTo-HtmlText $Scan.Scope)))
    [void]$builder.AppendLine(('<p class="notice">Listed: {0}; excluded: {1}; eligible: {2}; inspected: {3}; failed inspections: {4}; grouping fallbacks: {5}. Health counts describe inspected pipelines.</p>' -f
        $Scan.Listed,$Scan.Excluded,$Scan.Eligible,$Scan.Rows.Count,$Scan.Failures.Count,$Scan.GroupingFallbacks))
    $rows = @($Scan.Rows)
    if ($View -eq 'Red') {
        $redRows = @($rows | Where-Object Health -eq RED)
        if ($redRows.Count -eq 0) { [void]$builder.AppendLine('<p>No red pipelines among inspected results; see scan coverage above.</p>') }
        foreach ($group in ($redRows | Group-Object ProjectId -CaseSensitive | Sort-Object Name)) {
            [void]$builder.AppendLine('<h2>{0}</h2><table><caption>Red pipelines</caption><thead><tr><th scope="col">Pipeline</th><th scope="col">Observed streak start</th><th scope="col">Latest red build</th><th scope="col">Observed red builds</th></tr></thead><tbody>' -f (ConvertTo-HtmlText $group.Group[0].ProjectName))
            foreach ($row in ($group.Group | Sort-Object PipelineName,PipelineId)) {
                $since = Format-ReportInstant $row.OldestObservedRedAt
                if ($null -ne $row.OldestObservedRedAt -and -not $row.BoundaryObserved) { $since = 'At least since ' + $since }
                [void]$builder.AppendLine(('<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>' -f
                    (ConvertTo-SafeLink $row.PipelineUrl $row.PipelineName),
                    (ConvertTo-HtmlText $since), (ConvertTo-HtmlText (Format-ReportInstant $row.LatestAt)), $row.ObservedRedCount))
            }
            [void]$builder.AppendLine('</tbody></table>')
        }
    }
    elseif ($View -eq 'Summary') {
        [void]$builder.AppendLine((ConvertTo-HealthChartHtml -Rows $rows))
        [void]$builder.AppendLine('<table><caption>Health by immediate project ID</caption><thead><tr><th scope="col">Project</th><th scope="col">Inspected</th><th scope="col">Red</th></tr></thead><tbody>')
        foreach ($group in ($rows | Group-Object ProjectId -CaseSensitive | Sort-Object Name)) {
            [void]$builder.AppendLine(('<tr><td>{0} ({1})</td><td>{2}</td><td>{3}</td></tr>' -f
                (ConvertTo-HtmlText $group.Group[0].ProjectName), (ConvertTo-HtmlText $group.Name),
                $group.Count, @($group.Group | Where-Object Health -eq RED).Count))
        }
        [void]$builder.AppendLine('</tbody></table>')
    }
    else {
        foreach ($group in ($rows | Group-Object TopLevelProjectId -CaseSensitive | Sort-Object Name)) {
            [void]$builder.AppendLine(('<section><h2>{0} ({1})</h2>{2}</section>' -f
                (ConvertTo-HtmlText $group.Group[0].TopLevelProjectName), (ConvertTo-HtmlText $group.Name),
                (ConvertTo-HealthChartHtml -Rows @($group.Group))))
        }
        if ($rows.Count -eq 0) { [void]$builder.AppendLine('<p>No project data among inspected results.</p>') }
    }
    if ($Scan.Failures.Count -gt 0) {
        [void]$builder.AppendLine('<h2>Unavailable inspections</h2><ul>')
        foreach ($failure in $Scan.Failures) {
            [void]$builder.AppendLine(('<li>{0}: {1}</li>' -f (ConvertTo-HtmlText $failure.Id), (ConvertTo-HtmlText $failure.Reason)))
        }
        [void]$builder.AppendLine('</ul>')
    }
    [void]$builder.AppendLine('</body></html>')
    $builder.ToString()
}

function Export-HtmlArtifact {
    <#
    .SYNOPSIS
    Writes UTF-8 HTML through a temporary sibling file with preview support.
    .DESCRIPTION
    The parent directory must exist. Replaces one destination, without promising
    crash-proof atomicity or consistency across multiple report files.
    .PARAMETER LiteralPath
    Exact filesystem destination; wildcard expansion is not intended.
    .PARAMETER Html
    Already rendered HTML content.
    .OUTPUTS
    System.IO.FileInfo. No output when the write is declined or previewed.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param([Parameter(Mandatory)][string]$LiteralPath, [Parameter(Mandatory)][string]$Html)
    $destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LiteralPath)
    if ($PSCmdlet.ShouldProcess($destination, 'Write HTML artifact')) {
        $temporary = $destination + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
        try {
            [IO.File]::WriteAllText($temporary, $Html, [Text.UTF8Encoding]::new($false))
            [IO.File]::Move($temporary, $destination, $true)
        }
        finally {
            if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
        }
        Get-Item -LiteralPath $destination
    }
}
Export-ModuleMember -Function ConvertTo-PipelineReportHtml, Export-HtmlArtifact
