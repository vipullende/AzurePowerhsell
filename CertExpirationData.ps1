###########################################################################
#   This script is to get the list of certificates which are going to     #
#   expire in next 30 days                                                #
###########################################################################
#   Created by: Vipul Lende                                               #
###########################################################################

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

<# $username = "username"
$password = "password"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
Connect-AzAccount -Credential $creds #>

##E-Mail Details
$smtp = "xx.xxxxx.com"
$from = "xxxx@xxxxx.com"
$to = "xxx@xxx.com"
$cc = "xxx@xxx.com"

#Date
$Date = Get-Date -format ddMMyyyy-mmss

$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px;text-transform: capitalize; }
td { font-size: 15px; padding: 5px 20px; color: #ff0000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

$certinfo = @()
$Certtobexpired = @()
$list_subscription = Get-AzSubscription
foreach ($subscription in $list_subscription) {
    Set-AzContext -Subscription $subscription.Name
    $accesstoken = Get-AzAccessToken
    $header = @{
        'Authorization' = 'Bearer ' + $accesstoken.Token
    }

    $url = "https://management.azure.com/subscriptions/" + $subscription.Id + "/providers/Microsoft.CertificateRegistration/certificateOrders?api-version=2015-08-01"
    
    # $subscription
    $certinfo += Invoke-RestMethod -Uri $url -Headers $header -Method Get  | Select-Object -expand value
    
}

$Today = ([datetime] (Get-Date -format yyyy-MM-dd)).AddDays(60)
#pwd
#$Today.GetType()
$Certificates = $certinfo.properties  | Select-Object expirationTime, distinguishedName  #| Export-Csv -NoTypeInformation .\$date"certificate_info.csv"
                                                                                                                       
foreach ($Certificate in $Certificates) {
    if ($null -ne $Certificate.expirationTime -and [datetime] $Certificate.expirationTime -le $Today ) {
        Write-Host "Certificate expire for "  $Certificate.distinguishedName.Split("=").get(1)  " expiry date is "  $Certificate.expirationTime     
        $Certtobexpired += $Certificate
        $Certtobexpired 
    }   
}
$Certtobexpired |  Select-Object  @{Name = "Certificate Name"; Expression = { $_.distinguishedName } }, @{Name = "Expiration Date"; Expression = { $_.expirationTime } }  | Sort-Object -Property  "Name" -Descending | ConvertTo-Html -Head $css -Body "<h1>Certificate's. </h5>`n<h5>Generated on $(Get-Date)</h5>"  | Out-File .\$date"Certificate_Data.html"
if ($null -eq $Certtobexpired.expirationTime) {
    Write-Host "no email"
}else {
        #EMail Body
        $body = "Hi Team, <br>"
        $body += "Following Certificates are getting expire.  <br>"                 
        $body += Get-Content .\$date"Certificate_Data.html"
        #$body += Get-content VM_Count.html
        $body += "<br><br>"
        $body += "Thanks & Regards <br>"
        $body += " Team <br>"
        Write-Host "send email"
    
        #Sending E-maily
        #Send-MailMessage -SmtpServer $smtp  -Subject "Certificate Expiry Notification" -To $to  -From $from -BodyAsHtml $body
}





