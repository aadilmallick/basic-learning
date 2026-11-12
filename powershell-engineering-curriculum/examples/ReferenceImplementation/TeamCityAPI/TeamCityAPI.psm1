Set-StrictMode -Version Latest

class TeamCityClient {
    [uri]$RestRoot
    hidden [securestring]$Token
    hidden [scriptblock]$Transport
    hidden [Collections.Generic.Dictionary[string, object]]$ProjectCache

    TeamCityClient([uri]$root, [securestring]$token, [scriptblock]$transport) {
        $this.RestRoot = $root
        $this.Token = $token
        $this.Transport = $transport
        $this.ProjectCache = [Collections.Generic.Dictionary[string, object]]::new(
            [StringComparer]::Ordinal
        )
    }

    [object] Request([uri]$uri) {
        if ($uri.Scheme -ne 'https' -or $uri.IdnHost -ne $this.RestRoot.IdnHost -or
            $uri.Port -ne $this.RestRoot.Port -or $uri.UserInfo -or $uri.Fragment -or
            -not $uri.AbsolutePath.StartsWith($this.RestRoot.AbsolutePath, [StringComparison]::Ordinal)) {
            throw 'Request is outside the configured HTTPS REST boundary.'
        }
        return (& $this.Transport $uri $this.Token)
    }
}

function Invoke-TeamCityHttp {
    [CmdletBinding()]
    param([uri]$Uri, [securestring]$Token)
    Invoke-RestMethod -Uri $Uri -Method Get -Authentication Bearer -Token $Token `
        -Headers @{ Accept = 'application/json' } -TimeoutSec 30 `
        -MaximumRedirection 0 -ErrorAction Stop
}

function New-TeamCityClient {
    <#
    .SYNOPSIS
    Constructs an in-memory read-only reporting client without contacting a server.
    .PARAMETER Server
    HTTPS server root or REST root, including any deployment context path.
    .PARAMETER Token
    Nonempty bearer credential. Never returned as report data.
    .PARAMETER Transport
    Optional callback accepting a validated URI and SecureString token and returning
    one response object. Intended for controlled offline fixtures and testing.
    .OUTPUTS
    TeamCityClient. Use this factory for dynamic imports without caller type literals.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Creates only an in-memory object and performs no external effect.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][uri]$Server,
        [Parameter(Mandatory)][securestring]$Token,
        [scriptblock]$Transport = { param($uri, $token) Invoke-TeamCityHttp -Uri $uri -Token $token }
    )
    if (-not $Server.IsAbsoluteUri -or $Server.Scheme -ne 'https' -or
        $Server.UserInfo -or $Server.Query -or $Server.Fragment) {
        throw 'Server must be an absolute HTTPS URI without credentials, query, or fragment.'
    }
    if ($Token.Length -eq 0) { throw 'Token must not be empty.' }
    if ($null -eq $Transport) { throw 'Transport must not be null.' }
    $builder = [UriBuilder]::new($Server)
    $path = $builder.Path.TrimEnd('/')
    if (-not $path.EndsWith('/app/rest', [StringComparison]::OrdinalIgnoreCase)) {
        $path += '/app/rest'
    }
    $builder.Path = "$path/"
    [TeamCityClient]::new($builder.Uri, $Token, $Transport)
}

function New-TeamCityRequestUri {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Constructs only a URI value and performs no external effect.')]
    [CmdletBinding()]
    param([TeamCityClient]$Client, [string]$Path, [hashtable]$Query = @{})
    $builder = [UriBuilder]::new([uri]::new($Client.RestRoot, $Path))
    $parts = foreach ($key in ($Query.Keys | Sort-Object)) {
        '{0}={1}' -f [uri]::EscapeDataString($key), [uri]::EscapeDataString([string]$Query[$key])
    }
    $builder.Query = $parts -join '&'
    $builder.Uri
}

function Assert-TeamCitySimpleId {
    param([string]$Id)
    if ($Id -notmatch '^[A-Za-z0-9_-]+$') {
        throw 'This teaching client accepts only simple external IDs: letters, digits, underscore, hyphen.'
    }
}

function Get-TeamCityCollection {
    param(
        [TeamCityClient]$Client, [uri]$Uri, [string]$ItemName,
        [int]$Limit = [int]::MaxValue, [int]$MaxPages = 10000
    )
    $seenPages = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $seenIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $emitted = 0
    $pageCount = 0
    while ($null -ne $Uri) {
        $pageCount++
        if ($pageCount -gt $MaxPages -or -not $seenPages.Add($Uri.AbsoluteUri)) {
            throw 'Pagination repeated a URI or exceeded the page limit.'
        }
        $response = $Client.Request($Uri)
        if ($null -eq $response) { throw 'TeamCity returned no collection response.' }
        $itemsProperty = $response.PSObject.Properties[$ItemName]
        if ($null -eq $itemsProperty -or $null -eq $itemsProperty.Value) {
            throw "Response is missing the requested '$ItemName' collection."
        }
        foreach ($item in @($itemsProperty.Value)) {
            if ($null -eq $item) { throw 'Collection contains a null item.' }
            $idProperty = $item.PSObject.Properties['id']
            if ($null -eq $idProperty -or [string]::IsNullOrWhiteSpace([string]$idProperty.Value)) {
                throw 'Collection item is missing an ID.'
            }
            if ($seenIds.Add([string]$idProperty.Value)) {
                $item
                $emitted++
                if ($emitted -ge $Limit) { return }
            }
        }
        $nextProperty = $response.PSObject.Properties['nextHref']
        if ($null -eq $nextProperty -or [string]::IsNullOrWhiteSpace([string]$nextProperty.Value)) {
            return
        }
        $Uri = [uri]::new($Uri, [string]$nextProperty.Value)
        # Request() validates every destination before credentials reach the transport.
    }
}

function Get-TeamCityBuildType {
    <#
    .SYNOPSIS
    Lists non-template configurations using validated server continuation links.
    .PARAMETER Client
    A client created by New-TeamCityClient.
    .PARAMETER PageSize
    Requested page size, not a total-result limit or a snapshot guarantee.
    .OUTPUTS
    Zero or more raw configuration DTOs with the selected reporting fields.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][TeamCityClient]$Client, [ValidateRange(1,1000)][int]$PageSize = 100)
    $uri = New-TeamCityRequestUri -Client $Client -Path 'buildTypes' -Query @{
        locator = "templateFlag:false,count:$PageSize"
        fields = 'nextHref,buildType(id,name,projectName,projectId,webUrl)'
    }
    Get-TeamCityCollection -Client $Client -Uri $uri -ItemName 'buildType'
}

function ConvertFrom-TeamCityTimestamp {
    param([AllowNull()][string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    $normalized = $Text -replace '([+-]\d{2})(\d{2})$', '$1:$2'
    $formats = [string[]]@("yyyyMMdd'T'HHmmsszzz", "yyyyMMdd'T'HHmmss'Z'", 'O')
    $parsed = [DateTimeOffset]::MinValue
    $styles = [Globalization.DateTimeStyles]::AssumeUniversal
    if ([DateTimeOffset]::TryParseExact($normalized, $formats,
        [Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$parsed)) {
        return $parsed
    }
    # Unknown optional date remains unknown; it is never replaced with a fake instant.
    $null
}

function Get-TeamCityBuildHistory {
    <#
    .SYNOPSIS
    Reads bounded matching build observations in the server's supplied order.
    .PARAMETER Client
    A client created by New-TeamCityClient.
    .PARAMETER BuildTypeId
    Conservative simple external ID: letters, digits, underscore, or hyphen.
    .PARAMETER Limit
    Maximum observations returned. Finished, nonpersonal, noncanceled selection
    uses defaultFilter:false and no explicit branch selector.
    .OUTPUTS
    Zero or more normalized Id, Number, Status, FinishedAt, WebUrl observations.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][TeamCityClient]$Client,
        [Parameter(Mandatory)][string]$BuildTypeId,
        [ValidateRange(1,500)][int]$Limit = 100
    )
    Assert-TeamCitySimpleId $BuildTypeId
    $uri = New-TeamCityRequestUri -Client $Client -Path 'builds' -Query @{
        locator = "buildType:(id:$BuildTypeId),state:finished,personal:false,canceled:false,defaultFilter:false,count:$Limit"
        fields = 'nextHref,build(id,number,status,finishDate,webUrl)'
    }
    $raw = @(Get-TeamCityCollection -Client $Client -Uri $uri -ItemName 'build' -Limit $Limit)
    foreach ($build in $raw) {
        $statusProperty = $build.PSObject.Properties['status']
        if ($null -eq $statusProperty -or [string]::IsNullOrWhiteSpace([string]$statusProperty.Value)) {
            throw 'Build is missing a usable status.'
        }
        $dateProperty = $build.PSObject.Properties['finishDate']
        $numberProperty = $build.PSObject.Properties['number']
        $urlProperty = $build.PSObject.Properties['webUrl']
        [pscustomobject]@{
            Id = [string]$build.id
            Number = if ($numberProperty) { [string]$numberProperty.Value } else { '' }
            Status = ([string]$statusProperty.Value).ToUpperInvariant()
            FinishedAt = if ($dateProperty) { ConvertFrom-TeamCityTimestamp $dateProperty.Value } else { $null }
            WebUrl = if ($urlProperty) { [string]$urlProperty.Value } else { '' }
        }
    }
}

function Get-TeamCityProject {
    param([TeamCityClient]$Client, [string]$Id)
    Assert-TeamCitySimpleId $Id
    if (-not $Client.ProjectCache.ContainsKey($Id)) {
        $uri = New-TeamCityRequestUri -Client $Client -Path "projects/id:$Id" -Query @{
            fields = 'id,name,parentProject(id,name)'
        }
        $project = $Client.Request($uri)
        if ($null -eq $project -or [string]$project.id -cne $Id) {
            throw 'Project response does not match the requested ID.'
        }
        $Client.ProjectCache[$Id] = $project
    }
    $Client.ProjectCache[$Id]
}

function Resolve-TeamCityTopProject {
    <#
    .SYNOPSIS
    Resolves a project to the ancestor immediately below _Root.
    .PARAMETER Client
    Client owning the project cache. Successful lookups are reused per instance.
    .PARAMETER ProjectId
    Simple external project ID. Cycles, mismatches, and excessive depth fail.
    .OUTPUTS
    PSCustomObject with stable Id and display Name.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][TeamCityClient]$Client, [Parameter(Mandatory)][string]$ProjectId)
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $currentId = $ProjectId
    for ($depth = 0; $depth -lt 100; $depth++) {
        if (-not $seen.Add($currentId)) { throw 'Cycle in TeamCity project hierarchy.' }
        $current = Get-TeamCityProject -Client $Client -Id $currentId
        $parent = $current.PSObject.Properties['parentProject']
        if ($null -eq $parent -or $null -eq $parent.Value -or [string]$parent.Value.id -eq '_Root') {
            return [pscustomobject]@{ Id = [string]$current.id; Name = [string]$current.name }
        }
        $currentId = [string]$parent.Value.id
        if ([string]::IsNullOrWhiteSpace($currentId)) { throw 'Parent project has no usable ID.' }
    }
    throw 'Project hierarchy exceeded 100 levels.'
}

Export-ModuleMember -Function New-TeamCityClient, Get-TeamCityBuildType, Get-TeamCityBuildHistory, Resolve-TeamCityTopProject
