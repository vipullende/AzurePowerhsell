$WorkspaceId = '/subscriptions/3a962b01-218b-4afe-aaa6-aa403d44d61c/resourcegroups/rg_infssub_p_snt_eastus/providers/microsoft.operationalinsights/workspaces/log-infssub-p-snt-eastus-001'

Select-AzSubscription -Subscription "non-prod"
$logicapps = Get-AzEventHubNamespace | Where-Object Name -Like *pac* 
foreach($logicapp in $logicapps){
    $DiagnosticSettingName = 'diag' + '-' + $logicapp.Id.split('/')[-1]
    $DiagnosticSettingName 

Set-AzDiagnosticSetting -ResourceId $logicapp.Id -WorkspaceId $WorkspaceId -EnableLog $true  -EnableMetrics $true -Name $DiagnosticSettingName
}