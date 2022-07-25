
$WorkspaceId = 'id'

$subs = Get-AzSubscription  | Where-Object Name -like 'non-prod'
foreach ($sub in $subs) {
	select-AzSubscription -Subscription $sub.Name  
	$kvs = Get-AzResource | Where-Object { ($_.ResourceType -Like 'Microsoft.Network/applicationGateways' -or $_.ResourceType -Like 'Microsoft.KeyVault/vaults' -or $_.ResourceType -like 'Microsoft.Network/virtualNetworks'`
				-or $_.ResourceType -Like 'Microsoft.Network/frontdoors'`
				-or $_.resourceType -like 'Microsoft.DataFactory/factories') }
	foreach ($kv in $kvs) {
		$DiagnosticSettingName = 'diag' + '-' + $kv.name
		$DiagnosticSettingName
		$diags = Get-AzDiagnosticSetting -ResourceId $kv.ResourceId
		if (-not ($diags.WorkspaceId -contains $WorkspaceId)) {
			write-host 'ok do it'
			Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -WorkspaceId $WorkspaceId -EnableLog $true -Name $DiagnosticSettingName
		}
	}	
	}