using namespace System.Net
using namespace System.IO.Compression

# Input bindings are passed in via param block.
param(
    $Request, 
    $TriggerMetadata
)

$Values = $Request.RawBody | ConvertFrom-Json 
$PathName = ('{0}\ZipDeploy\{1}' -f $env:temp, (Get-Random -Minimum 1000 -Maximum 9999))
$PathZipFile = ('{0}\{1}' -f $env:temp, (Get-Random -Minimum 1000 -Maximum 9999))
$FileHashes = [System.Collections.Generic.List[PSObject]]::New()

Write-Output '###################################'
Write-Output $Request.RawBody 
Write-Output '###################################'

# Create Directory
Write-Output "Directory creation"
try {
    $null = New-Item -ItemType Directory -Path $PathName -ErrorAction Stop
    $Result = $true
}
catch {
    Write-Output $_.Exception.Message
}

if ($Result -eq $true) {
    foreach ($File in $Values | Where-Object { $_.contentBytes.length -gt 0}) {
        # write file to disk
        $ByteArr = [System.Convert]::FromBase64String($File.contentBytes)
        [System.IO.File]::WriteAllBytes(('{0}\{1}' -f $PathName, $File.Name), $ByteArr)

        # get the item
        $i = Get-Item -Path ('{0}\{1}' -f $PathName, $File.Name)

        # Get file hash
        $Hash = Get-FileHash -Algorithm SHA256 -Path $i.FullName | Select-Object Algorithm,Hash,@{Name="FileName"; E={ ('{0}{1}' -f $_.Hash, $i.Extension) }}
        if ($Hash.Hash.Length -gt 0 -and $Hash.FileName.Length -gt 0)
        {
            $FileHashes.Add($Hash)
        }

        # Rename file
        Rename-Item -Path $i.FullName -NewName ('{0}\{1}{2}' -f $PathName, $Hash.Hash, $i.Extension)
    }
}

if ((Get-ChildItem -Path $PathName -ErrorAction SilentlyContinue).Count -gt 0)
{
    Write-Output "Zip file creation"
    try {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($PathName, $PathZipFile)
        if (Test-Path -Path $PathZipFile -ErrorVariable Stop)
        {
            $ByteArr = [System.Io.File]::ReadAllBytes($PathZipFile)
            $Return = [PSCustomObject]@{
                ContentBytes = [System.Convert]::ToBase64String($ByteArr)
                Hashes = $FileHashes
                Status = 'Success'
            } | ConvertTo-Json
        } else {
            $Return = [PSCustomObject]@{
                ContentBytes = ''
                Hashes = @([PSCustomObject]@{
                    Algorithm = ''
                    FileName = ''
                    Hash = ''
                })
                Status = 'Error'
            } | ConvertTo-Json
        }
    }
    catch {
        Write-Output $_.Exception.Message
    }
} else {
    $Return = [PSCustomObject]@{
        ContentBytes = ''
        Hashes = @([PSCustomObject]@{
            Algorithm = ''
            FileName = ''
            Hash = ''
        })
        Status = 'Error'
    } | ConvertTo-Json
}


# try to remove the files and folder
Write-Output "Remove items"
Remove-Item -Path $PathZipFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $PathName -Force -ErrorAction SilentlyContinue -Recurse

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Return
    })





