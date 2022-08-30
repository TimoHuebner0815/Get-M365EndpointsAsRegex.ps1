# .PARAMETER TenantName
#  TenantName=<tenant_name> —Your Office 365 tenant name. The web service takes your provided name and inserts it in parts of URLs
#  that include the tenant name. If you don't provide a tenant name, those parts of URLs have the wildcard character (*).
# .PARAMETER ServiceAreas
#  ServiceAreas=<Common | Exchange | SharePoint | Skype> —A comma-separated list of service areas. Valid items are Common, Exchange,
#  SharePoint, and Skype. Because Common service area items are a prerequisite for all other service areas, the web service always
#  includes them. If you do not include this parameter, all service areas are returned.
# .PARAMETER Instance
#  Instance=<Worldwide | China | USGovDoD | USGovGCCHigh> —This required parameter specifies the instance from which to return the
#  endpoints. Valid instances are: Worldwide, China, USGovDoD, and USGovGCCHigh.

param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $TenantName,
    [Parameter(Mandatory = $false)]
    [ValidateSet('Common', 'Exchange', 'Sharepoint', 'Skype')]
    [String] $ServiceAreas,
    [Parameter(Mandatory = $false)]
    [ValidateSet('Worldwide', 'China', 'USGovDoD', 'USGovGCCHigh')]
    [String] $Instance = "Worldwide"
)
#Variables
$Regex = @()

#Functions
function Get-Regex
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Fqdn
    )
    return "^https?://" + $Fqdn.Replace(".", "\.").Replace("*", "[A-Za-z0-9.-]*")
}

function Get-Endpoints
{
    Param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String] $Instance,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [guid] $ClientRequestId = [guid]::NewGuid()
    )
    $baseServiceUrl = "https://endpoints.office.com/endpoints/$Instance/?ClientRequestId={$ClientRequestId}"
    $url = $baseServiceUrl
    if ($TenantName)
    {
        $url += "&TenantName=$TenantName"
    }
    if ($ServiceAreas)
    {
        $url += "&ServiceAreas=" + ($ServiceAreas -Join ",")
    }
    return Invoke-RestMethod -Uri $url
}

#Code
$Endpoints = Get-Endpoints -Instance $Instance

foreach ($Endpoint in $Endpoints)
{
    foreach ($url in $Endpoint.urls)
    {

        $Regex += (Get-Regex -Fqdn $url)
    }   
}

$Regex
$Regex | Set-Clipboard