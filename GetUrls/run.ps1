using namespace System.Net
using namespace System.IO.Compression

# Input bindings are passed in via param block.
param(
    $Request, 
    $TriggerMetadata
)

$UrlsNew = [System.Collections.Generic.List[PSObject]]::New()
$RegEx = 'protection.outlook.com/\?url='
$Replace = ('^.*{0}' -f $RegEx)


if ($Request.RawBody.length -gt 0)
{
   
    $Values = $Request.RawBody | ConvertFrom-Json 
    $Urls = $Values.Urls.Split(' ')

    foreach ($Url in $Urls) {
        # Check if Url match microsoft Protection hostnames
        if ($Url -match $RegEx)
        {
            # Decode the Uri string and replace microsoft Protection string
            $UrlsNew.add([PscustomObject]@{
                Url = [System.Web.HttpUtility]::UrlDecode(($Url -replace($Replace)))
            })
        } else {
            # If not put it in as it is.
            $UrlsNew.add([PscustomObject]@{
                Url = $Url
            })
        }
    }

    # Remove double Urls
    $UrlsNew = $UrlsNew | Select-Object -Unique -Property Url
    # Convert Urls to json
    $Return = $UrlsNew | ConvertTo-Json
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Return
})





