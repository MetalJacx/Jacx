Function New-vCDLogin{
     <#
    .SYNOPSIS
    Starts a session with vCloud Director(vCD) API's
    .DESCRIPTION
    This session will be used for for the following Get-* Write-* and Commit-* Delete-* commands in this Module
    .PARAMETER Uri
    The IP address or the FQDN of the base vCD Portal
    .PARAMETER Username
    The user with the correct level of access to leverage vCD, make sure to include @<organizationname>. The organization name is what follows https://domain.com/tenant/<organizationname>. Service Provider level admins will leverage @system.
    .PARAMETER Password
    The password associated with leveraged Username
    .PARAMETER APIV
    The version of API you wish to leverage with this connection
    .PARAMETER skipcert
    This optional parameter is used if you need to skip SSL cert verification. Not recommended for production.
    .EXAMPLE
    New-vCDLogin -URI http://<IP or FQDN> -Username 'user@org' -password 'userpass' -apiv '31.0' 
    .EXAMPLE
    New-vCDLogin -URI http://<IP or FQDN> -Username 'user@org' -password 'userpass' -apiv '31.0' -skipcert
    .NOTES
    APIV the api version you want to use (Current:31.0 as of 1/13/2019)
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            If ($_ -match "^https:\/\/.*"){
                $True
            }   
            else {
                Throw "$_ Please levearge https:// to the begining or your IP or FQDN."
            }
        })]
        [string]$Uri,
        [Parameter(Mandatory=$true)]
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
        [Parameter(Mandatory=$true)]
        [Alias("pass")]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [ValidateSet("30.0","31.0")]
        [String]$apiv,
        [Parameter(Mandatory=$false)]
        [switch]$skipcert
    )
   
    Write-Host Connecting to "" -ForegroundColor Green -NoNewline; Write-Host "$Uri" "" -NoNewline; Write-Host as "" -ForegroundColor Green -NoNewline; 
    Write-Host $Username "" -NoNewline; Write-Host with API version "" -ForegroundColor Green -NoNewline; Write-Host $apiv

    $Global:Uri = $Uri
    $Global:apiv = $apiv
    $Global:skipcert = If ($skipcert.IsPresent){$true} else{$false}
    $Global:Bearer = ""
    $ErrorActionPreference = "Stop"
    
    $Pair = "$($Username):$($Password)"
    $Bytes = [System.Text.Encoding]::ASCII.GetBytes($Pair)
    $Base64 = [System.Convert]::ToBase64String($Bytes)
    $Authorization = "Basic $Base64"    
    $headers = @{ "Authorization" = $Authorization; "Accept" = "application/*+xml;version=$Global:apiv"}
    $Password = ""
    IF ($skipcert.IsPresent){
        $Res = Invoke-WebRequest -SkipCertificateCheck -Method Post -Headers $headers -Uri "$($Global:Uri)/api/sessions"
    }
    else {
        $Res = Invoke-WebRequest -Method Post -Headers $headers -Uri "$($Global:Uri)/api/sessions"
    }
    $Global:Bearer = $res.headers["X-VMWARE-VCLOUD-ACCESS-TOKEN"]
    $xvcloudauthorization = $res.headers["x-vcloud-authorization"]

    Write-Host ...
    Write-Host Connection Accepted and Session Token Created -ForegroundColor Green
    Write-Host Session Key: "" -ForegroundColor Y -NoNewline; Write-Host $xvcloudauthorization
    Write-Host Bearer Key: "" -ForegroundColor Y -NoNewline; Write-Host $Global:Bearer
    }

Function Invoke-vcd{
    IF ($global:skipcert -match "True"){
        Invoke-WebRequest -SkipCertificateCheck -Method $method -Headers $headers -body $body -Uri "$($Global:Uri)/$EndPoint"
    }
    else {
        Invoke-WebRequest -Method $method -Headers $headers -body $body -Uri "$($Global:Uri)/$EndPoint"
    }
}

Function Get-vCDRequest{
    <#
    .SYNOPSIS
    Uses the define session to invoke GETs from vCloud Director(vCD) API's
    .DESCRIPTION
    Ths command will run get command against your supplied endpoint
    .PARAMETER Endpoint
    This is your define target for the API calls that is place after the URI if writing out the full command
    .EXAMPLE
    Stand API (XML)
    Get-vCDRequest -endpoint api/org
    .EXAMPLE
    New CloudApi (JSON)
    Get-vCDRequest -endpoint cloudapi/branding
    .NOTES
    Enpoint is the rest of the api command after Https://<IP or FQDN>
    #>
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({
            If ($_ -match "^api|^cloudapi"){
                $True
            }
            else {
                Throw "Please make sure to include api/ or cloudapi/ with your endpoint"
            }
        })]
        [Alias("ep")]
        [string]$Endpoint
    )
    $method = "get"

    If ($Endpoint -match "^cloudapi"){
        $Global:Bearer = "Bearer $Global:Bearer"
        $headers = @{"Accept" = "application/json;version=$Global:apiv"; "Authorization" = $Global:Bearer}
        $Response = Invoke-vcd
        Return $Response
    }
    else{
        $Global:Bearer = "Bearer $Global:Bearer"
        $headers = @{"Accept" = "application/*+xml;version=$Global:apiv"; "Authorization" = $Global:Bearer}
        $Response = Invoke-vcd
    Return $Response
    }
}

# Body is either XML or JSON file
# Type  either XML or JSON depending on the file you will be uploading

Function Write-vCDRequest{
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({
            If ($_ -match "^api|^cloudapi|^transfer"){
                $true
            }
            else {
                Throw "Please make sure to include api/, transfer/, or cloudapi/ with your endpoint"
            }
        })]
        [Alias("ep")]
        [string]$Endpoint,
        [Parameter(Mandatory=$true, position=1)]
        [ValidateSet("xml","json","binary")]
        [String]$Type,
        [Parameter(Mandatory=$true, position=2)]
        $Body
    )
    $method = "Put"

    If ($Type -match "^api|^cloudapi"){
        $Global:Bearer = "Bearer $Global:Bearer"
        $Global:Type = "application/$Type"
        $Body = [IO.FILE]::ReadAllText($Body)
        $headers = @{"Authorization" = $Global:Bearer; "Content-Type" = $Global:Type}
        $Response = Invoke-vcd
        Return $Response
    }
    else {
        $Global:Bearer = "Bearer $Global:Bearer"
        $Global:Type = "application/$Type"
        $headers = @{"Authorization" = $Global:Bearer; "Content-Type" = $Global:Type}
        IF ($global:skipcert -match "True"){
            $Response = Invoke-WebRequest -SkipCertificateCheck -InFile $body -Method Put -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
        }
        else {
            $Response = Invoke-WebRequest -InFile $body -Method Put -Headers $headers -Uri "$($Global:Uri)/$EndPoint"
        }
            Return $Response
    }
}
Function Submit-vCDRequest{
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
        [string]$Endpoint,
        [Parameter(Mandatory=$true, position=1)]
        [ValidateSet("xml","json","binary")]
        [string]$Type,
        [Parameter(Mandatory=$false, position=2)]
        $Body
    )

    $method = "Post"

    $Global:Bearer = "Bearer $Global:Bearer"
    $Global:Type = "application/$Type"
    $Body = [IO.FILE]::ReadAllText($Body)
    $headers = @{"Authorization" = $Global:Bearer; "Content-Type" = $Global:Type}
    $Response = Invoke-vcd
    Return $Response
}

