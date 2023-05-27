
$WorkspaceId = '/subscriptions/3a962b01-218b-4afe-aaa6-aa403d44d61c/resourcegroups/rg_infssub_p_snt_eastus/providers/microsoft.operationalinsights/workspaces/log-infssub-p-snt-eastus-001'

$subs = Get-AzSubscription | Where-Object Name -Like "non-prod"
foreach ($sub in $subs) {
	select-AzSubscription -Subscription $sub.Name   
	$kvs = Get-AzResource -ResourceGroupName rg_nonpsub_l_pac_westus2 | Where-Object { ($_.ResourceType -Like 'Microsoft.Web/sites') }
	foreach ($kv in $kvs) {
		$DiagnosticSettingName = 'diag' + '-' + $kv.ResourceId.split('/')[-1]
		$DiagnosticSettingName
		$diags = Get-AzDiagnosticSetting -ResourceId $kv.ResourceId

			write-host 'ok do it'
			Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -WorkspaceId $WorkspaceId -EnableLog $true  -EnableMetrics $true -Name $DiagnosticSettingName
		}	
	}

