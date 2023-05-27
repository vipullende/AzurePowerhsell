#Install-Module -Name Az.NetAppFiles -force$date = Get-Date -format ddMMyyyy-mmss
$date = Get-Date -format ddMMyyyy-mmss
$datee = (Get-Date -f 'dd MMM yyyy') 
$report = @()
#$nonpRGs = 'rg_nonpsub_d_sap_s4h_wkz_westus2' , 'rg_nonpsub_d_sap_s4h_wkz_westus2', 'rg_nonpsub_m_hld_westus2'
$subscriptions = Get-AzSubscription


foreach ($subscription in $subscriptions) {
    Select-AzSubscription -Subscription $subscription.Name
    $netAppAccountNames = Get-AzResource | where {($_.ResourceType -Like  'Microsoft.NetApp/netAppAccounts')}
    foreach ($netAppAccountName in $netAppAccountNames) {
        $netAppVolumePools = Get-AzNetAppFilesPool -ResourceGroupName $netAppAccountName.ResourceGroupName -AccountName $netAppAccountName.Name
        foreach ( $netAppVolumePool in  $netAppVolumePools) {
            $Volumes = Get-AzNetAppFilesVolume -ResourceGroupName $netAppAccountName.ResourceGroupName -AccountName $netAppAccountName.Name  -PoolName $netAppVolumePool.Name.split('/')[-1]

            foreach ($Volume in $Volumes) {
                $dataMetricsLogicalSpaceFile = (Get-AzMetric -ResourceId $Volume.Id -MetricName 'VolumeLogicalSize' -AggregationType Average).Data

                $info = '' | Select-Object NetAppName, VolumeName, QuotaGB, UsedQuotaGB, UsedQuotaPercent
                $Info.NetAppName = $Volume.name.split('/')[0]
                $info.VolumeName = $Volume.name.split('/')[-1]
                $info.QuotaGB = $Volume.UsageThreshold / 1GB
                $info.UsedQuotaGB = [math]::Floor($dataMetricsLogicalSpaceFile[$dataMetricsLogicalSpaceFile.Count - 2].Average / 1GB)
                $info.UsedQuotaPercent = [math]::round($dataMetricsLogicalSpaceFile[$dataMetricsLogicalSpaceFile.Count - 2].Average / $Volume.UsageThreshold * 100)
                $report += $info
            }
        }
    }
}
$report | Export-Csv  -NoTypeInformation ./NetAppVolumes.csv