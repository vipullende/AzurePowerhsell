####Credit Vipul

$StorageAccountUsage = @()
$UsedCapacity = @()
$StorageAccounts = @()
$Report = @()
$StorageUsageReport = @() 
$Subscriptions = @()
$Subscription = @()

$Subscriptions = get-azsubscription

$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 15px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
foreach ($Subscription in $Subscriptions) {
    Select-AzSubscription -SubscriptionId $Subscription.SubscriptionId
    $StorageAccounts = Get-AzStorageAccount 
    foreach ($StorageAccount in $StorageAccounts) {

        $UsedCapacity = Get-AzMetric -ResourceId $StorageAccount.id  -MetricName "UsedCapacity"
        $Report = " " | Select "StorageAccount Name", "Used Capacity in GB", "SKU Name", "AccessTier","Subscription Name"
        $Report."StorageAccount Name" = $StorageAccount.StorageAccountName
        $Report."Used Capacity in GB" = [math]::Round($UsedCapacity.Data.Average / 1Gb, 2)
        $Report."SKU Name" = $StorageAccount.sku.name
        $Report."AccessTier" = $storageAccount.accesstier
        $Report."Subscription Name"= $Subscription.name
        $StorageUsageReport += $Report
    }
}
$StorageUsageReport | Sort-Object -Property  "Used Capacity in GB" -Descending | Export-Csv -NoTypeInformation .\storageaccountusage21102021.csv
#| ConvertTo-Html -Head $css -Body "<h1>Storage Account Usage. </h5>`n<h5>Generated on $(Get-Date)</h5>" | Out-File ./Azure_StorageAccount_Usage.html

#[math]::Round($UsedCapacity.Data.Average / 1Gb)

#$snapshots  = Get-AzSnapshot | ?{$_.Sku.Tier -like "Premium"}

#get-AzDisk 
