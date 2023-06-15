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
$payload = '{
    "schemaId": "azureMonitorCommonAlertSchema",
    "data": {
        "essentials": {
            "alertId": "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/providers/Microsoft.AlertsManagement/alerts/1f30405d-16b6-4994-9d70-ab0b2d792c36",
            "alertRule": "cona-Certificate Expiry",
            "severity": "Sev5",
            "signalType": "Metric",
            "monitorCondition": "Fired",
            "monitoringService": "Platform",
            "alertTargetIDs": [
                "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/resourcegroups/rg_nonpsub_m_pcl_westus2/providers/microsoft.network/applicationgateways/agw_nonpsub_m_pcl_002"
            ],
            "configurationItems": [
                "agw_nonpsub_m_pcl_002"
            ],
            "originAlertId": "5d26aadf-bc83-45db-908e-d9f69c2d27b9_rg_nonpsub_m_pcl_westus2_Microsoft.Insights_metricAlerts_agwfr-m-pcl-alert_-1096020369",
            "firedDateTime": "2023-05-31T22:15:37.428032Z",
            "resolvedDateTime": "2023-05-31T23:30:28.7494125Z",
            "description": "Cerificate is ging to exipre in 45 days",
            "essentialsVersion": "1.0",
            "alertContextVersion": "1.0"
        },
        "alertContext": {
            "properties": {
                "assignmentGroup": "77f382fe6ff80300e906841dba3ee458"
            },
            "conditionType": "DynamicThresholdCriteria",
            "condition": {
                "windowSize": "PT15M",
                "allOf": [
                    {
                        "alertSensitivity": null,
                        "failingPeriods": null,
                        "ignoreDataBefore": null,
                        "metricName": "FailedRequests",
                        "metricNamespace": "Microsoft.CertificateRegistration/certificateOrders",
                        "operator": null,
                        "threshold": null,
                        "timeAggregation": "Total",
                        "dimensions": [
                            {
                                "name": "ExpiryDateTime",
                                "value": "DateTime"
                            }
                        ],
                        "metricValue": null,
                        "webTestName": null
                    }
                ],
                "windowStartTime": "2023-05-31T23:12:24.931Z",
                "windowEndTime": "2023-05-31T23:27:24.931Z"
            }
        },
        "customProperties": {
            "AssignmentGroup": "77f382fe6ff80300e906841dba3ee458"
        }
    }
}'
#########################################################

$logicurl = "https://prod-15.westus2.logic.azure.com:443/workflows/d5c58bdcbda64ac4be946da2d6529e0e/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qCjbyjGxbgXX-2vK7dYMMVAZEXXzt2Lej9AM9QSbu4Y"
###################
$certinfo = @()
$Certtobexpired = @()
$list_subscription = Get-AzSubscription  |  Where-Object Name -notlike Access* 
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
$data = $payload | ConvertFrom-Json
$Today = ([datetime] (Get-Date -format yyyy-MM-dd)).AddDays(60)
#pwd
#$Today.GetType()
$Certificates = $certinfo.properties  | Select-Object expirationTime, distinguishedName  #| Export-Csv -NoTypeInformation .\$date"certificate_info.csv"
                                                                                                                       
foreach ($Certificate in $Certificates) {
    if ($null -ne $Certificate.expirationTime -and [datetime] $Certificate.expirationTime -le $Today ) {
        Write-Host "Certificate expire for "  $Certificate.distinguishedName.Split("=").get(1)  " expiry date is "  $Certificate.expirationTime     
        
        $data = $payload | ConvertFrom-Json 
        $data.data.essentials.configurationItems[0] =  $Certificate.distinguishedName.Split("=").get(1)
        $data.data.essentials.firedDateTime = Get-Date -Format "o"
        $data.data.alertContext.condition.allOf.dimensions[0].value = $Certificate.expirationTime
        $datanew = $data | ConvertTo-Json  -Depth 20
        Invoke-RestMethod -Method Post -Uri $logicurl -Body ($datanew) -ContentType "application/json"

        $Certtobexpired += $Certificate

        

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





