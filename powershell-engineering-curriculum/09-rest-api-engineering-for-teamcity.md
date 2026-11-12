# Stage 9: REST API Engineering for TeamCity

> **Audience:** Intermediate PowerShell developer progressing to maintainable, modular, object-oriented PowerShell/.NET engineering.  
> **Environment:** PowerShell 7.4+ recommended; verify compatibility separately for Windows PowerShell 5.1 and the actual CI agent.  
> **Method:** First-principles explanation, runnable isolated examples, realistic design tradeoffs, and connection to the uploaded TeamCity reporting script. No quizzes or active-recall prompts.  
> **Source note:** TeamCity-specific observations are derived from the supplied `New-RedTeamCityPipelineHtmlReport.txt`; general language/design material is instructional background. No live TeamCity access or runtime validation is claimed.

## An API client is more than Invoke-RestMethod
It must encode URLs, authenticate, paginate, normalize response shapes, handle failures, and expose predictable objects. Keep network details inside `TeamCityAPI`.

### Constructing requests
```powershell
function Invoke-TeamCityRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Token
    )
    $root = "$($BaseUrl.TrimEnd('/'))/app/rest"
    $uri = "$root/$($Path.TrimStart('/'))"
    Invoke-RestMethod -Method Get -Uri $uri -Headers @{
        Accept='application/json'
        Authorization="Bearer $Token"
    } -ErrorAction Stop
}
```
Use only with a trusted, configured server and a caller-controlled relative path. A production implementation should validate the server scheme/host, handle an already-suffixed `/app/rest`, escape path segments, and build query parameters separately. Avoid string interpolation for untrusted query values.

### Query encoding
```powershell
$query = @{ fields='count,nextHref,buildType(id,name)'; locator='count:100,start:0' }
$parts = foreach ($key in $query.Keys) {
    '{0}={1}' -f [uri]::EscapeDataString([string]$key),
                 [uri]::EscapeDataString([string]$query[$key])
}
$parts -join '&'
```
The source script uses this same `EscapeDataString` approach. Distinguish query encoding from path-segment encoding and do not double-encode an already escaped value.

### Pagination
The source fetches `buildTypes` with `start`/`count` and checks `nextHref`. A robust client should either follow the server-provided next link after validating it belongs to the expected API origin, or use a documented offset contract consistently. Terminate on missing/empty pages and detect repeated continuation links to prevent loops. Do not assume `count` means the number returned on this page without checking API semantics.

### Normalize variable response shapes
```powershell
function Get-ArrayProperty {
    param([object]$Response,[string]$Name)
    if ($null -eq $Response) { return ,@() }
    $property = $Response.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return ,@() }
    return ,@($property.Value)
}
```
Use `@(Get-ArrayProperty ...)` carefully because PowerShell enumeration semantics can surprise you; design one documented contract and test zero, one, and multiple results. Treat absent JSON fields as expected variability only when the API permits them.

### Rate limits and cache
A per-client cache of `projectId → projectInfo` avoids repeated hierarchy lookups. Cache lifetime, invalidation, and concurrency should be explicit. Do not cache credentials or errors indefinitely. Respect HTTP 429 and `Retry-After` when available; only retry transient conditions.

### Security
Use HTTPS, protected CI secrets, least-privilege API tokens, and redacted diagnostics. Do not disable TLS validation to 'fix' certificate problems. Never construct a report link from untrusted text without URL validation and HTML attribute encoding. The source encodes attribute text but still deserves a URL-scheme allowlist review.

### Source-specific correctness
The build history query excludes personal and canceled builds and asks for finished builds. Define exactly what 'latest' means: API ordering must be verified rather than assumed. If a failed build streak reaches the scan limit without a non-red build, label it as a lower bound ('at least since'), not an exact failure start. Date offsets should be retained until presentation.
