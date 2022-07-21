
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

# Get-AzDiagnosticSetting -ResourceId "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/resourceGroups/rg_nonpsub_m_pcl_westus2/providers/Microsoft.Network/applicationGateways/agw_nonpsub_m_pcl_002"

# Set-AzDiagnosticSetting -ResourceId "/subscriptions/3a8d651a-33d8-46be-89b8-8cf0436d27dd/resourceGroups/rg_prodsub_p_ato_eastus/providers/Microsoft.KeyVault/vaults/conakeyvault2024" -WorkspaceId $WorkspaceId -EnableLog $true  -Name "test"