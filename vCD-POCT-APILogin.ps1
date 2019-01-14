# Username used to login into vCloud Director; Don't Forgot to @Org (Service Provider Administrator are @system)
# Password goes with the above username
# URI is your Https://<IP or FQDN>;; Leave off api this is due to Vmware now introducing /cloudapi/ when workign with themes
# APIV the api version you want to use (Current:31.0 as of 1/13/2019)

Function New-vCDLogin($Username,$Password,$Uri,$apiv){
    $Global:Accept = "application/*+xml;version=$apiv"
    $Global:Uri = $Uri
    $Pair = "$($Username):$($Password)"
    $Bytes = [System.Text.Encoding]::ASCII.GetBytes($Pair)
    $Base64 = [System.Convert]::ToBase64String($Bytes)
    $Global:Authorization = "Basic $Base64"
    $headers = @{ "Authorization" = $Global:Authorization; "Accept" = $Global:Accept}
    $Res = Invoke-WebRequest -SkipCertificateCheck -Method Post -Headers $headers -Uri "$($Global:Uri)/api/sessions"
    $Global:xvCloudAuthorization = $res.headers["X-VMWARE-VCLOUD-ACCESS-TOKEN"]
}

# Enpoint is the rest of the api command after Https://<IP or FQDN>
# Example One: -endpoint "api/org"
# Example Two: -endpoint "cloudapi/branding"

Function Get-vCDRequest($EndPoint){
    $Global:Bearer = "Bearer $Global:xvCloudAuthorization"
    $headers = @{"Accept" = $Global:Accept; "Authorization" = $Global:Bearer}
    $Response = Invoke-WebRequest -SkipCertificateCheck -Method Get -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
    Return $Response
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