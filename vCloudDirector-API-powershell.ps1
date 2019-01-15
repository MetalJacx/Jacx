# Username used to login into vCloud Director; Don't Forgot to @Org (Service Provider Administrator are @system)
# Password goes with the above username
# URI is your Https://<IP or FQDN>;; Leave off api this is due to Vmware now introducing /cloudapi/ when workign with themes
# APIV the api version you want to use (Current:31.0 as of 1/13/2019)

Function New-vCDLogin{
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({
            If ($_ -match "^https:\/\/.*"){
                $True
            }   
            else {
                Throw "$_ Please levearge https:// to the begining or your IP or FQDN."
            }
        })]
        [string]$Uri,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateScript({
            If ($_ -match "^.*\@.*"){
                $True
            }
            else {
                Throw "Please make sure to include your Organization (Example <username>@<Org>)."
            }
        })]
        [Alias("user")]
        [string]$Username,
        [Parameter(Mandatory=$true, Position=2)]
        [Alias("pass")]
        [string]$Password,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateSet("30.0","31.0")]
        [String]$apiv
    ) 
    
    Write-Host Connecting to "" -ForegroundColor Green -NoNewline; Write-Host "$Uri" "" -NoNewline; Write-Host as "" -ForegroundColor Green -NoNewline; 
    Write-Host $Username "" -NoNewline; Write-Host with API version "" -ForegroundColor Green -NoNewline; Write-Host $apiv 

    $Global:Accept = "application/*+xml;version=$apiv"
    $Global:Uri = $Uri
    $Global:apiv = $apiv
    $Pair = "$($Username):$($Password)"
    $Bytes = [System.Text.Encoding]::ASCII.GetBytes($Pair)
    $Base64 = [System.Convert]::ToBase64String($Bytes)
    $Global:Authorization = "Basic $Base64"
    $headers = @{ "Authorization" = $Global:Authorization; "Accept" = $Global:Accept}
    $Res = Invoke-WebRequest -SkipCertificateCheck -Method Post -Headers $headers -Uri "$($Global:Uri)/api/sessions"
    $Global:xvCloudAuthorization = $res.headers["X-VMWARE-VCLOUD-ACCESS-TOKEN"]


    Write-Host ...
    Write-Host Connection Accepted and Session Token Created -ForegroundColor Green
    Write-Host key: "" -ForegroundColor Y -NoNewline; Write-Host $Global:xvCloudAuthorization
    }

# Enpoint is the rest of the api command after Https://<IP or FQDN>
# Example One: -endpoint "api/org"
# Example Two: -endpoint "cloudapi/branding"

Function Get-vCDRequest{
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({
            If ($_ -match "^api|^cloudapi"){
                $True
            }
            else {
                Throw "Please make sure to include /api or /cloudapi with your endpoint"
            }
        })]
        [Alias("ep")]
        [string]$Endpoint
    )

    If ($Endpoint -match "^cloudapi"){
        $Global:Bearer = "Bearer $Global:xvCloudAuthorization"
        $headers = @{"Accept" = "application/json;version=$Global:apiv"; "Authorization" = $Global:Bearer}
        $Response = Invoke-WebRequest -SkipCertificateCheck -Method Get -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
        Return $Response
    }
    else{
    $Global:Bearer = "Bearer $Global:xvCloudAuthorization"
    $headers = @{"Accept" = $Global:Accept; "Authorization" = $Global:Bearer}
    $Response = Invoke-WebRequest -SkipCertificateCheck -Method Get -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
    Return $Response
    }
}

# Body is either XML or JSON file
# Type  either XML or JSON depending on the file you will be uploading

Function Put-vCDRequest($EndPoint,$Body,$Type){
    $Global:Bearer = "Bearer $Global:xvCloudAuthorization"
    $Global:Type = "application/$Type"
    $GLobal:Body = [IO.FILE]::ReadAllText($Body)
    $headers = @{"Authorization" = $Global:Bearer; "Content-Type" = $Global:Type}
    $Response = Invoke-WebRequest -SkipCertificateCheck -Body $Global:body -Method Put -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
    Return $Response
}
Function Post-vCDRequest($EndPoint,$Body,$Type){
    $Global:Bearer = "Bearer $Global:xvCloudAuthorization"
    $Global:Type = "application/$Type"
    $GLobal:Body = [IO.FILE]::ReadAllText($Body)
    $headers = @{"Authorization" = $Global:Bearer; "Content-Type" = $Global:Type}
    $Response = Invoke-WebRequest -SkipCertificateCheck -Body $Global:body -Method Post -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
    Return $Response
}

