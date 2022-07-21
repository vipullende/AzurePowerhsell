
$WorkspaceId = '/subscriptions/3a962b01-218b-4afe-aaa6-aa403d44d61c/resourcegroups/rg_infssub_p_snt_eastus/providers/microsoft.operationalinsights/workspaces/log-infssub-p-snt-eastus-001'

$subs = Get-AzSubscription | Where-Object Name -like 'production' 
foreach ($sub in $subs) {
	select-AzSubscription -Subscription $sub.Name  
	$kvs = Get-AzResource | Where-Object {($_.ResourceType -Like 'Microsoft.Network/applicationGateways' -or $_.ResourceType -Like'Microsoft.KeyVault/vaults')}
	foreach ($kv in $kvs) {
		$DiagnosticSettingName = 'diag' + '-' + $kv.name
		$DiagnosticSettingName
		$diag = Get-AzDiagnosticSetting -ResourceId $kv.ResourceId
		if ($diag.WorkspaceId -ne $WorkspaceId ) {
			write-host 'ok do it'
			Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -WorkspaceId $WorkspaceId -EnableLog $true -Name $DiagnosticSettingName
		}	
	}
}
