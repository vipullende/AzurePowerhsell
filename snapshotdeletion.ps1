$subs = Get-AzSubscription | Where-Object Name -notlike Access*
$snapShotsToBedeleted = @()
#$snapShotsToBeMailed = @()
foreach ($Sub in $subs) {
    Select-AzSubscription  -SubscriptionName $sub.Name 
    $snapShots = Get-AzSnapshot
    #$DaysOld = ([datetime] (Get-Date -format yyyy-MM-dd)).AddDays(-45)
    foreach ($snapShot in $snapShots) {
        if ([datetime] $snapShot.TimeCreated -lt ([datetime] (Get-Date -format yyyy-MM-dd)).AddDays(-60)) {
            Write-Host 'Delete' $snapShot.Name  $snapShot.TimeCreated $snapShot.Sku.Name
            $snapShotsToBedeleted += $snapShot
            Write-Host 'delete'
           # Remove-AzSnapshot -ResourceGroupName $snapshot.ResourceGroupName -SnapshotName $snapShot.Name -Force;

        }
    }
}
$snapShotsToBedeleted.CreationData[0]
