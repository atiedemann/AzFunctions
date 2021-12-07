using namespace System.Net

# Input bindings are passed in via param block.
param(
  $Request, 
  $TriggerMetadata
)

# Interact with query parameters or the body of the request.
$Value = $Request.Query.Name
if (-not $name) {
  $Value = $Request.Body.Name
}


# IP List private networks
[regex]$IpPrivate = '^10\.|^127\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.'

# Build arraylist
$IPs = [System.Collections.Generic.List[PSObject]]::New()

# Replace unwanted characters
$Value = $Value -replace ('\[') -replace ('\]') -replace ('\(') -replace ('\)') -replace ('\s', ' ')
$value = $Value -split (' ')

foreach ($i in $Value) {
  if ($i -match '\.' -or $i -match ':' -and $i -notmatch $IpPrivate) {
    try {
      $null = [ipaddress]$i
      $IPs.Add($i)
    }
    catch {

    }
  }
}

if ($IPs.Count -gt 0) {
  $Content = $IPs | ConvertTo-Json
}
else {
  $Content = '{ "Status": "failed" }'
}


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $Content
  })