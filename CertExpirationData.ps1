###########################################################################
#   This script is to get the list of certificates which are going to     #
#    expire in next 30 days                                               #
###########################################################################
#   Created by: Vipul Lende                                               #
###########################################################################




$certinfo = @()
$Certtobexpired =@()
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

$Today = ([datetime] (Get-Date -format yyyy-MM-dd)).AddDays(30)

#$Today.GetType()
$Certificates = $certinfo.properties  | Select-Object expirationTime, distinguishedName  #| Export-Csv -NoTypeInformation ./certificate_info.csv
                                                                                                                       
foreach ($Certificate in $Certificates) {
    if ($null -ne $Certificate.expirationTime -and [datetime] $Certificate.expirationTime -le $Today ) {
        Write-Host "Certificate expire for "  $Certificate.distinguishedName.Split("=").get(1)  " expiry date is "  $Certificate.expirationTime     
       $Certtobexpired += $Certificate
    }   
    $Certtobexpired 
}