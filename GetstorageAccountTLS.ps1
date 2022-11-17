

$subs = Get-AzSubscription | Where-Object Name -like 'production'
$stg = @()
foreach ($sub in $subs) {
    select-AzSubscription -Subscription $sub.Name 
    $storageAccounts = Get-AzStorageAccount | Where-Object ResourceGroupName -notlike *pac* 
    foreach ($accountName in $storageAccounts) {
        # Read the MinimumTlsVersion property.MinimumTlsVersion
        $tls = (Get-AzStorageAccount -ResourceGroupName $accountName.ResourceGroupName -Name $accountName.StorageAccountName).MinimumTlsVersion
        $allowedIP = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $accountName.ResourceGroupName -AccountName $accountName.StorageAccountName 
       
        $allowedIP.IpRules 
        if ($tls -eq 'TLS1_2') {
            write-host 'Hurry' $accountName.StorageAccountName 'is fine'
        }
        else {
            write-host 'need to change tls to 1.2 for storage account' $accountName.StorageAccountName
            Set-AzStorageAccount -ResourceGroupName $accountName.ResourceGroupName `
            -Name $accountName.StorageAccountName `
            -MinimumTlsVersion TLS1_2
        }
        if ($allowedIP.DefaultAction -contains 'Deny') {

            $stg += $accountName
            if ($allowedIP.IpRules.ipaddressorrange -notcontains '10.10.10.10') {
                Write-Host 'add 10.10.10.10' 
                Add-AzStorageAccountNetworkRule -ResourceGroupName $accountName.ResourceGroupName`
                    -AccountName $accountName.StorageAccountName -IPAddressOrRange '161.162.158.164'
            }

            if ($allowedIP.IpRules.ipaddressorrange -notcontains '10.10.10.11') {
                Write-Host 'add 10.10.10.11' 
                Add-AzStorageAccountNetworkRule -ResourceGroupName $accountName.ResourceGroupName`
                    -AccountName $accountName.StorageAccountName -IPAddressOrRange '10.10.10.11'
            }
            if ($allowedIP.IpRules.ipaddressorrange -notcontains '10.10.10.12') {
                Write-Host 'add 10.10.10.12' 
                Add-AzStorageAccountNetworkRule -ResourceGroupName $accountName.ResourceGroupName`
                    -AccountName $accountName.StorageAccountName -IPAddressOrRange '10.10.10.12'
            }
        }
    }
}