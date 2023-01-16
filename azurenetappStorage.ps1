$Volumes = Get-AzNetAppFilesVolume -ResourceGroupName rg_nonpsub_q_sap_s4h_wkz_westus2 -AccountName anf_nonpsub_q_sap_s4h_westus2  -PoolName cp_q_sap_s4h_westus2_001
$date = Get-Date -format ddMMyyyy-mmss
$report = @()
foreach ($Volume in $Volumes) {
    $dataMetricsLogicalSpaceFile = (Get-AzMetric -ResourceId $Volume.Id -MetricName 'VolumeLogicalSize' -AggregationType Average).Data

    $info = '' | Select-Object NetAppName, VolumeName, QuotaTB, UsedQuotaGB, UsedQuotaPercent
    $Info.NetAppName = $Volume.name.split('/')[0]
    $info.VolumeName = $Volume.name.split('/')[-1]
    $info.QuotaTB = $Volume.UsageThreshold / 1TB
    $info.UsedQuotaGB = [math]::Floor($dataMetricsLogicalSpaceFile[$dataMetricsLogicalSpaceFile.Count - 2].Average / 1GB)
    $info.UsedQuotaPercent = [math]::round($dataMetricsLogicalSpaceFile[$dataMetricsLogicalSpaceFile.Count - 2].Average / $Volume.UsageThreshold * 100)
    $report += $info
}
###################################################################################

$HTMLOfReport = @'
<style>
BODY{background-color:white;}
TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;foreground-color: black;background-color: LightBlue}
TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;foreground-color: black}
.green{background-color:#d5f2d5}
.blue{background-color:#e0eaf1}
.red{background-color:#ffd7de}
</style>
<body>
<table>
    <tr>
        <th>Net App Name</th>
        <th>Volume Name</th>
        <th>Quota TB</th>
        <th>Used Quota GB</th>
        <th>Used Quota Percent</th>
    </tr>
'@

$report = $report | Sort-Object -Property 'UsedQuotaPercent' -Descending

for ($i = 0; $i -lt $report.Count; $i++) {

    if ($report[$i].UsedQuotaPercent -gt 90) {     
        $HTMLOfReport += '<tr style=''background-color:red''>'
    }
    elseif ($report[$i].UsedQuotaPercent -gt 80) {
        $HTMLOfReport += '<tr style=''background-color:yellow''>'        
    }
    else {
        $HTMLOfReport += '<tr>'  
    }
    $HTMLOfReport += '  <td>' + $report[$i].NetAppName + '</td>
                        <td>'+ $report[$i].VolumeName + '</td>
                        <td>'+ $report[$i].QuotaTB + '</td>
                        <td>'+ $report[$i].UsedQuotaGB + '</td>
                        <td>'+ $report[$i].UsedQuotaPercent + '</td></tr>'
}
$HTMLOfReport += '</table></body>'
$HTMLOfReport | Out-File .\$date"_Data.html"


