$subs = Get-AzSubscription |  Where-Object Name -notlike Access* # |Where-Object Name -Like production
$stg = @()
$arraydata = @()
$allowedIPAddress = @('161.162.174.164', '161.162.158.164', '20.185.96.41')

foreach ($sub in $subs) {
    select-AzSubscription -Subscription $sub.Name 
    $storageAccounts = Get-AzStorageAccount | Where-Object ResourceGroupName -notlike *pac* # | Where-Object StorageAccountName -like 'dlspaseeastus001'
    foreach ($accountName in $storageAccounts) {
        $allowedIP = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $accountName.ResourceGroupName -AccountName $accountName.StorageAccountName 
        if ($allowedIP.DefaultAction -contains 'Deny') {

            $stg += $accountName
          
            foreach ($notallowed in $allowedIP.IpRules.ipaddressorrange) {
                if ($allowedIPAddress -notcontains $notallowed  ) {
                   
                    Write-Host $notallowed
                    $Report = " " | Select StorageAccountName, NotallowedIP
                    $Report.StorageAccountName +=  $accountName.StorageAccountName
                    $Report.NotallowedIP +=  $notallowed
                    $arraydata += $Report 

                    # Remove-AzStorageAccountNetworkRule -ResourceGroupName $accountName.ResourceGroupName`
                    #     -AccountName $accountName.StorageAccountName -IPAddressOrRange $notallowed
                }
            }
        }
    }
}


$arraydata | Export-Csv  -NoTypeInformation .\NotAllowedIp.csv
