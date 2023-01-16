$subs = Get-AzSubscription | Where-Object Name -notlike Access* 
$stg = @()
$arraydata = @()
$BulkIP =""
$i = 0
$allowedIPAddress = @('1.16.174.16', '1.16.18.164', '20.18.9.41')

foreach ($sub in $subs) {
    select-AzSubscription -Subscription $sub.Name 
    $storageAccounts = Get-AzStorageAccount | Where-Object ResourceGroupName -notlike *pac* # | Where-Object StorageAccountName -like 'dlspaseeastus001'
    foreach ($accountName in $storageAccounts) {
        $allowedIP = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $accountName.ResourceGroupName -AccountName $accountName.StorageAccountName 
        if ($allowedIP.DefaultAction -contains 'Deny') {

            $stg += $accountName
            
          
            foreach ($notallowed in $allowedIP.IpRules.ipaddressorrange) {
                
                if ($allowedIPAddress -notcontains $notallowed  ) {
                    $BulkIP = $BulkIP + $notallowed +","
                    $Report = ' ' | Select StorageAccountName, NotallowedIP, IPRegion, IPCountry, Organization
                    $Report.StorageAccountName += $accountName.StorageAccountName
                    $IPGeolocation = Invoke-RestMethod -Method Get -Uri "https://ipapi.co/$notallowed/json/"
                   
                    
                    $Report.NotallowedIP += $notallowed
                    $Report.IPRegion = $IPGeolocation.region
                    $Report.IPCountry = $IPGeolocation.country_name
                    $Report.organization = $IPGeolocation.org

                    $arraydata += $Report 

                    # Remove-AzStorageAccountNetworkRule -ResourceGroupName $accountName.ResourceGroupName`
                    #     -AccountName $accountName.StorageAccountName -IPAddressOrRange $notallowed
                }
            }
            #$BulkIP.TrimEnd(",");
        }
    }
}


$arraydata | Export-Csv  -NoTypeInformation .\NotAllowedIp.csv
