$NamecheapURL = "https://www.namecheap.com/api/v1/ncpl/landingpages/gateway/getdomainspricingdetails"
$DomainTLDs = @(
    "com", "net", "org", "io", "co", "ai", "co.uk", "ca", "dev", "me", "de", "app", "in", "is", "eu",
    "gg", "to", "ph", "nl", "id", "inc", "website", "xyz", "club", "online", "info", "store", "best",
    "live", "us", "tech", "pw", "pro", "uk", "tv", "cx", "mx", "fm", "cc", "world", "space", "vip",
    "life", "shop", "host", "fun", "biz", "icu", "design", "art"
)

function Get-DomainPricingDetails {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int]$Years = 10,
        [validateSet("OnlyTlds","ExceptTlds" )]
        [string]$Type = "ExceptTlds"
    )

    $Body = "{`"request`":{`"Term`":`"`",`"Duration`":$Years,`"TldsRequestType`":`"$($Type)`",`"Tlds`":$($DomainTLDs | Join-String -Separator '","' -OutputPrefix '["' -OutputSuffix '"]')}}"
    Write-Verbose "Sending request to $NamecheapURL with body: $Body"

    $response = Invoke-WebRequest -UseBasicParsing -Uri $NamecheapURL `
        -Method "POST" `
        -ContentType "text/plain;charset=UTF-8" `
        -Body $Body

    $flattenedList = $response.Content | ConvertFrom-Json | Select-Object Tld, DisableWhoisGuardAllot, NeedsExtendedAttributes, HasAdditionalCost,
        TldType, @{Name="Price"; Expression={$_.Register.Price}},
        @{Name="PricingHint"; Expression={$_.Register.PricingHint}},
        @{Name="PricingMode"; Expression={$_.Register.PricingMode}},
        @{Name="RegularPrice"; Expression={$_.Register.RegularPrice}},
        Renew, Transfer, Country, RegistrarLockSupported, DnsSecSupported, IdnSupported

    return $flattenedList
}