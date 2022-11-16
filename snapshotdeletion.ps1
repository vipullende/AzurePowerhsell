#######################################################################
#  Created by: Vipul Lende                                           #
######################################################################

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
# $head = @'
# <style>
# BODY{background-color:white;}
# TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
# TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;foreground-color: black;background-color: LightBlue}
# TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;foreground-color: black;background-color: white}
# .green{background-color:#d5f2d5}
# .blue{background-color:#e0eaf1}
# .red{background-color:#ffd7de}
# </style>
# '@
# $snapShotsToBedeleted | select Name, TimeCreated |  ConvertTo-Html -Head $head -Body "<h1>Snapshots which are deleted</h5>`n<h5>Generated on $(Get-Date)</h5>"   | Out-File .\$date"_Data.html"

# $snapShotsToBedeleted.Count