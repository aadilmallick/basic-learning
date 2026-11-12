# Stage 9 — REST API engineering for TeamCity

An API client is a translator between an unreliable external system and the smaller, more stable concepts your application needs. It should not simply expose `Invoke-RestMethod` everywhere. This chapter develops URI construction, authentication, locators, pagination, normalization, time, caching, and operational limits. Offline examples use PowerShell 7.4+ and fabricated data. A block labeled **Live-use pattern** requires an authorized server and is not part of offline execution.

## 9.1 Understand the request and response contract

HTTP supplies methods, URLs, headers, status codes, and bodies. TeamCity adds resource paths, locator expressions, field projections, and collection pagination. PowerShell adds object deserialization and error records. Each layer has its own grammar and failure modes.

A GET request asks for a representation of a resource. `Accept: application/json` asks for JSON. A bearer token authorizes access according to its permissions; it does not determine which fields your code validates or which branches your report includes. HTTPS protects transport, while your code must still avoid logging credentials or sending them to an unintended destination.

The client should expose operations such as “list configurations” and “read bounded build history,” returning documented data. It should keep authentication mechanics and continuation links behind that boundary. TeamCity's [REST API overview](https://www.jetbrains.com/help/teamcity/rest/teamcity-rest-api-documentation.html) describes the server-specific model.

## 9.2 Construct the REST root deliberately

A TeamCity deployment can live under a context path such as `/teamcity/`. Resolving `/app/rest/` from the host root would discard that context. Conversely, accepting a URL already ending in `/app/rest/` should not append the segment twice.

**Offline example 1 — normalize a server URI without losing its context.**

```powershell
function New-RestRoot {
    param([Parameter(Mandatory)][uri]$Server)
    if (-not $Server.IsAbsoluteUri -or $Server.Scheme -ne 'https') {
        throw 'Use an absolute HTTPS server URI.'
    }
    if ($Server.UserInfo -or $Server.Query -or $Server.Fragment) {
        throw 'Server URI must not contain credentials, query, or fragment.'
    }
    $builder = [UriBuilder]::new($Server)
    $path = $builder.Path.TrimEnd('/')
    if (-not $path.EndsWith('/app/rest', [StringComparison]::OrdinalIgnoreCase)) {
        $path += '/app/rest'
    }
    $builder.Path = "$path/"
    $builder.Uri
}
New-RestRoot -Server 'https://ci.example.com/teamcity/'
New-RestRoot -Server 'https://ci.example.com/teamcity/app/rest/'
```

Both results point to the same REST root. The trailing slash makes relative child-resource resolution predictable. This example accepts only server roots or REST roots by contract; it does not attempt to interpret an arbitrary resource URL as configuration.

Validate URI components structurally rather than searching the entire input string with a loose regular expression. A query containing `/app/rest` is not evidence that the path is a REST root. Avoid credentials embedded in URLs because they can appear in logs, exceptions, browser history, and monitoring.

## 9.3 Encode query components and validate locator values

TeamCity locators use punctuation such as commas, colons, and parentheses. URL encoding protects their transport inside a query string. It does not protect the locator's own grammar after the server decodes it. An arbitrary identifier containing locator punctuation can still change the expression's meaning.

**Offline example 2 — keep encoding and validation separate.**

```powershell
$buildTypeId = 'Backend_Build'
if ($buildTypeId -notmatch '^[A-Za-z0-9_-]+$') {
    throw 'This example accepts only simple TeamCity external IDs.'
}
$query = [ordered]@{
    locator = "buildType:(id:$buildTypeId),state:finished,personal:false,canceled:false,defaultFilter:false,count:100"
    fields = 'nextHref,build(id,number,status,finishDate,webUrl)'
}
$parts = foreach ($key in $query.Keys) {
    '{0}={1}' -f [uri]::EscapeDataString($key), [uri]::EscapeDataString($query[$key])
}
'https://ci.example.com/app/rest/builds?' + ($parts -join '&')
```

The conservative ID rule is an explicit limitation of this teaching client, not a claim about every historical TeamCity identifier. If your deployment uses a wider character set, implement the server's documented locator escaping rather than removing validation without replacement.

Field projection reduces response size and clarifies required data. If you plan to follow pagination, request continuation metadata such as `nextHref` along with items. A projection that requests only `build(...)` cannot support reliable continuation discovery. See [locators](https://www.jetbrains.com/help/teamcity/rest/locators.html) for locator syntax and pagination semantics.

## 9.4 Authentication belongs to the transport boundary

**Live-use pattern — supply credentials at runtime.**

```powershell
# Live-use pattern: provide your own approved endpoint and token.
$server = [uri]'https://ci.example.com/app/rest/buildTypes'
$token = Read-Host 'TeamCity access token' -AsSecureString
$request = @{
    Uri = $server
    Method = 'Get'
    Authentication = 'Bearer'
    Token = $token
    Headers = @{ Accept = 'application/json' }
    TimeoutSec = 30
    MaximumRedirection = 0
    ErrorAction = 'Stop'
}
# Invoke-RestMethod @request
```

The final call is commented so copying the block does not contact a fabricated server. `SecureString` integrates with the web cmdlet's bearer-token parameter. It does not mean the secret is inaccessible to the authenticated process, and protection differs by platform. The API still needs usable credential material to authenticate.

Environment variables are convenient for CI, but the application should read them at the entry boundary rather than burying the lookup in a domain function. Do not include token values in command-line arguments or diagnostics. Use the organization's secret injection mechanism and a token with the permissions the read-only report requires.

Redirect handling needs a policy. This example rejects redirects so an unexpected server response cannot silently change the authenticated destination. A production deployment that requires redirects should validate the intended redirect chain rather than broadly preserving authorization to arbitrary locations. Supported parameters are documented in [Invoke-RestMethod](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod).

## 9.5 Pagination is a protocol, not a loop-size guess

A collection response may contain fewer items than requested and still provide a continuation. A response's count can describe the current page rather than the full universe. Follow the server's continuation contract instead of assuming a full page is the only reason to continue.

**Offline example 3 — follow a continuation even after a short page.**

```powershell
$pages = @{
    first = [pscustomobject]@{
        buildType = @([pscustomobject]@{ id = 'A' })
        nextHref = 'second'
    }
    second = [pscustomobject]@{
        buildType = @([pscustomobject]@{ id = 'B' })
        nextHref = ''
    }
}
$seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$next = 'first'
while ($next) {
    if (-not $seen.Add($next)) { throw 'Repeated continuation detected.' }
    $page = $pages[$next]
    foreach ($item in @($page.buildType)) { $item.id }
    $next = [string]$page.nextHref
}
```

The outputs are A and B. The seen set prevents an infinite cycle if a server or fixture repeats a continuation. A maximum page count supplies another operational bound. Neither mechanism makes the collection a consistent snapshot while the server is changing; deduplicate by ID and document the scan's observation window.

Do not rebuild a continuation by incrementing your own offset unless the API explicitly guarantees that strategy. The continuation may carry filters, lookup state, or paging details you did not model. TeamCity documents using `nextHref` to navigate collection pages in its [build retrieval guide](https://www.jetbrains.com/help/teamcity/rest/get-build-details.html).

## 9.6 A continuation must not redirect credentials elsewhere

Treat a returned URL as external data. Resolve relative continuations against the current request, then require the approved HTTPS origin and REST path before attaching authentication. An origin includes scheme, host, and effective port. A path prefix check should include the trailing slash to avoid accepting `/app/rest-evil/`.

**Offline example 4 — validate the next destination.**

```powershell
$root = [uri]'https://ci.example.com/teamcity/app/rest/'
$current = [uri]'https://ci.example.com/teamcity/app/rest/buildTypes?locator=count%3A100'
$next = [uri]::new($current, '/teamcity/app/rest/buildTypes?locator=start%3A100')
$sameOrigin = $next.Scheme -eq $root.Scheme -and
    $next.IdnHost -eq $root.IdnHost -and $next.Port -eq $root.Port
$insideRest = $next.AbsolutePath.StartsWith($root.AbsolutePath, [StringComparison]::Ordinal)
if (-not $sameOrigin -or -not $insideRest -or $next.UserInfo -or $next.Fragment) {
    throw 'Continuation is outside the approved REST boundary.'
}
$next.AbsoluteUri
```

This is a meaningful trust boundary because the client attaches credentials. HTML links have a different policy: a report may permit approved HTTPS links to build pages outside the REST prefix. Do not reuse a request-destination validator as if every URL context had the same requirements.

## 9.7 Define what “latest” and “pipeline” mean

The uploaded script inspects finished, nonpersonal, noncanceled builds and disables TeamCity's default build filter. Disabling that filter changes the candidate set; the default filter also relates to default-branch behavior and failed-to-start builds. Consult the [BuildLocator reference](https://www.jetbrains.com/help/teamcity/rest/buildlocator.html) and verify on the target server.

The script does not explicitly choose a branch. Therefore its report should not be casually described as default-branch-only. A red feature-branch build may affect a configuration-level result depending on the returned set. Branch scope is a business choice: all branches, default branch, or a named branch pattern. Put it in the data-source contract and report metadata.

Ordering also needs a definition. Newest by server build sequence is not necessarily newest by finish time when builds overlap. The original algorithm trusts the API sequence. A compatible refactor should preserve that sequence and verify its meaning with the server, rather than silently sorting by a different timestamp and changing streak membership.

TeamCity documents common status values such as `SUCCESS`, `FAILURE`, and `UNKNOWN`. The source script additionally maps `ERROR` to red. Preserve that as a local compatibility rule without claiming it is a universal server status. Unknown future values should remain visible as raw status and classify conservatively.

## 9.8 Bounded history is bounded evidence

`MaxBuildsToScan = 100` means “inspect up to one hundred matching observations,” not “the streak began within one hundred builds.” If the oldest inspected build is still red, the boundary is unobserved. Retention can remove older builds, and server-side lookup limits can affect results independently of your requested count.

A robust history reader follows pages until it reaches the application limit or no continuation remains. It should not fetch the whole history merely because the server provides more. A result can carry the requested limit, observed count, and whether a continuation remained. The analyzer then expresses what it can infer from the observations.

The teaching implementation keeps “At least since” whenever no non-red boundary is observed, even if history happens to be exhausted. That matches the source's conservative operational wording. It does not infer the actual defect introduction time from a build's finish time.

## 9.9 Dates and normalization

TeamCity timestamps commonly use compact text such as `20261112T090000-0500`. Normalize the numeric offset for exact parsing, use invariant culture, and retain `DateTimeOffset`. Convert to a chosen timezone only when presenting the report.

**Offline example 5 — parse the documented compact form.**

```powershell
$raw = '20261112T090000-0500'
$normalized = $raw -replace '([+-]\d{2})(\d{2})$', '$1:$2'
$instant = [DateTimeOffset]::ParseExact(
    $normalized,
    "yyyyMMdd'T'HHmmsszzz",
    [Globalization.CultureInfo]::InvariantCulture
)
$instant.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
```

The result is `2026-11-12 14:00:00 +00:00`. The original script converts to machine-local `DateTime`, which makes displayed text dependent on where the script runs. That is a presentation choice to revisit explicitly, not an arithmetic bug to hide during extraction.

For malformed optional timestamps, return an explicit unknown and record diagnostics if needed. For required timestamps used to order data, fail rather than assigning a default ancient date. Do not use broad culture-dependent parsing as the only parser for a documented machine format.

## 9.10 Caching and hierarchy traversal

Project IDs are better cache keys than names. Cache project responses per client, and cache final ancestor resolutions when that saves repeated traversal. Distinguish a missing parent from a lookup failure. Detect cycles and impose a depth limit even if the normal server model is a tree; defensive traversal should terminate on malformed fixture or response data.

Grouping by a top-level name is convenient for readers but can merge distinct entities with identical labels. Carry both ID and name through the model, group by ID, and render the name. If lookup fails and you fall back to an immediate project name, mark the grouping quality so readers know it is approximate.

Avoid premature parallelization. First reduce redundant calls through field projection and caching. If latency remains unacceptable, use bounded independent workers with their own supported client/runspace state and a clear rate-limit policy. A shared hashtable cache is not a complete concurrency design.

## 9.11 Interpret HTTP errors before choosing recovery

An HTTP response can fail at several layers. A connection failure may produce no HTTP status at all. A 401 response suggests authentication needs attention; 403 suggests authorization; 404 can mean an absent resource or an incorrect route; 429 signals throttling; selected 5xx responses may be transient. These are starting points for policy, not a reason to retry every response in a numeric range.

Do not parse an English exception message to find a status if the error exposes structured response data. PowerShell and .NET exception shapes can vary by runtime, so normalize them inside the transport adapter into safe diagnostic fields. Keep the original error record available internally for troubleshooting.

A successful HTTP status is not enough either. HTML from a login page, an unexpected JSON object, or a missing requested collection can still be unusable. Validate content shape before calling it a successful lookup. Conversely, a legitimate empty collection should remain a successful observation.

**Offline example 6 — classify response shape without contacting a server.**

```powershell
function Get-RequiredCollection {
    param([Parameter(Mandatory)][psobject]$Response, [string]$Name)
    $property = $Response.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        throw "Response does not contain the required '$Name' collection."
    }
    foreach ($item in @($property.Value)) { $item }
}
$emptyResponse = [pscustomobject]@{ build = @() }
"Valid empty count: $(@(Get-RequiredCollection -Response $emptyResponse -Name build).Count)"
try {
    Get-RequiredCollection -Response ([pscustomobject]@{ message = 'unexpected' }) -Name build
}
catch { 'Rejected an incompatible response shape' }
```

The distinction is deliberate and testable. A production client should verify what the target TeamCity version emits for an empty projected collection. If that version legitimately omits the collection field, adapt the normalization rule based on documented evidence and fixtures rather than treating all missing fields as valid emptiness.

For retry delay, `Retry-After` can be a number of seconds or an HTTP date. A robust policy handles valid forms, caps unreasonable delays, and respects the overall scan deadline. Jitter helps avoid synchronized retries from many agents. The teaching client intentionally leaves this policy unimplemented so its current behavior is explicit; adding it is a bounded transport enhancement, not a change to pipeline health.

## 9.12 What the offline reference does and what live verification remains

The bundled client demonstrates endpoint validation, encoded query construction, continuation checks, page bounds, per-client project caching, and a replaceable transport. The offline tests prove those mechanics against controlled responses. They do not prove a particular TeamCity server's permissions, branch behavior, ordering, retention, or plugin-specific fields.

Before adopting the client in a real report job, make a small authorized read-only comparison against known configurations: one green, one red with a known boundary, one with no builds, and one spanning branches. Compare raw responses with the report's stated scope. This is deployment validation of external assumptions, separate from the deterministic language and domain tests that can run everywhere.

## 9.13 Analyze selection before interpreting status

A health result is only meaningful relative to the selected builds. Consider a configuration with a successful default-branch build, a failed feature-branch build, and a canceled experimental build. “Latest build is red” can be true or false depending on branch and cancellation filters. The classifier cannot repair a source query that selected the wrong universe.

Define the scope in ordinary language first: which configurations, which branches, which build states, personal or shared builds, canceled or noncanceled, and how much history. Then translate that scope into documented locator dimensions. Keep the ordinary-language scope in report metadata so readers do not need to reverse-engineer a URL to understand the result.

The uploaded script chooses finished, nonpersonal, noncanceled builds and disables default filtering, but does not explicitly choose a branch. The teaching client retains that selection to avoid silently changing the case study. It therefore labels its scope honestly instead of claiming to represent only the default branch.

Configuration selection is separate from build selection. Excluding a project name removes configurations before their histories are read. A branch selector changes which observations belong to each retained configuration. A history limit bounds evidence after filtering. Conflating these steps can produce misleading performance and completeness claims.

Also distinguish “not selected” from “unavailable.” An excluded configuration is outside the report's chosen scope. A forbidden configuration was intended to be inspected but could not be. The scan envelope should preserve that distinction because readers may reasonably accept one and investigate the other.

## 9.14 Reason about order and concurrent server changes

A paginated collection can change while you read it. New builds may arrive, configurations may be added, and permissions may change. Following a continuation is necessary, but it does not automatically create a point-in-time snapshot. Deduplication prevents some repeated items from being counted twice; it does not prove no item was missed.

For a periodic report, it may be sufficient to describe the result as observations collected during a scan window. If a stronger snapshot is required, investigate server-supported bounding selectors or another consistency mechanism and validate it for the deployed version. Do not invent a client-side guarantee by sorting the final array.

Ordering is similarly contextual. A build sequence can differ from finish-time order because builds overlap. Suppose build 102 starts first but finishes after build 103. Sorting by finish time changes which observation is treated as latest. The report needs an operational definition that matches its intended use.

The original analyzer trusts the server's sequence. The teaching analyzer requires newest-first input under that same chosen sequence. Its parameter name expresses the precondition, while live integration validation establishes whether the adapter satisfies it. Pure tests can prove the loop honors an order; they cannot prove a remote server supplied the intended order.

When timestamps are missing, do not silently substitute IDs as chronological values unless the server contract justifies that relationship. Treat IDs as identifiers. A numeric-looking ID is not automatically a timestamp, and a build number can be a custom string. Preserve the actual source ordering and record the uncertainty you cannot resolve.

## 9.15 Make API diagnostics useful without publishing raw requests

A failed lookup should identify the operation and safe resource identity. An operator benefits from knowing that configuration `Backend_Build` history failed on attempt two with a timeout. They rarely need the full authorization header or an arbitrary response body in the saved report.

Normalize diagnostics near transport: safe status code when available, request operation, elapsed time, attempt count, and a correlation identifier if the server supplies one. Retain the original error internally when appropriate. Publish a sanitized summary to report readers. This keeps operational evidence without making HTML a dump of exception internals.

Be careful with URLs in logs. Query strings can contain sensitive user-supplied selectors, and a general-purpose client may later support more than the read-only patterns shown here. Select the safe fields you need rather than assuming every URI is suitable for unrestricted publication.

Fixture design should exercise the same diagnostics boundaries. Include a missing collection, a malformed required status, an invalid optional date, a foreign continuation, and a deliberate request failure. Each should produce its documented outcome. If all failures collapse into an empty build list, the client has lost the distinctions the report depends on.

Finally, keep external assumptions visible during maintenance. TeamCity upgrades, changed token permissions, new branch conventions, and altered retention policies can change observations without any source-code change. A small integration comparison on known configurations is therefore a useful complement to unit tests after such changes. It verifies the adapter's assumptions while leaving deterministic business tests fast and offline.

Do not infer historical completeness solely from a missing continuation. The selected fields, server behavior, retention, and query scope all influence what you received. The safest streak claim remains tied to observed evidence: a non-red boundary was seen, or it was not. This keeps the analyzer honest even when the client has reached the end of the available response sequence.
