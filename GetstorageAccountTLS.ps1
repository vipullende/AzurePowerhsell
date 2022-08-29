

$subs = Get-AzSubscription #| Where-Object Name -like 'production'
foreach ($sub in $subs) {
    select-AzSubscription -Subscription $sub.Name 
    $storageAccounts = Get-AzStorageAccount
    foreach ($accountName in $storageAccounts) {
        # Read the MinimumTlsVersion property.MinimumTlsVersion
        $tls = (Get-AzStorageAccount -ResourceGroupName $accountName.ResourceGroupName -Name $accountName.StorageAccountName).MinimumTlsVersion
        if ($tls -eq 'TLS1_2') {
            write-host 'Hurry' $accountName.StorageAccountName 'is fine'
        }
        else {
            write-host 'need to change tls to 1.2 for storage account' $accountName.StorageAccountName
            Set-AzStorageAccount -ResourceGroupName $accountName.ResourceGroupName `
            -Name $accountName.StorageAccountName `
            -MinimumTlsVersion TLS1_2
        }
    }
}