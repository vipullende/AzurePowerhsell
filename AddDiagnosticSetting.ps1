
$WorkspaceId = 'id'

$subs = Get-AzSubscription  
foreach ($sub in $subs) {
	select-AzSubscription -Subscription $sub.Name  
	$kvs = Get-AzResource | Where-Object { ($_.ResourceType -Like 'Microsoft.Network/applicationGateways' -or $_.ResourceType -Like 'Microsoft.KeyVault/vaults' -or $_.ResourceType -like 'Microsoft.Network/virtualNetworks'`
				-or $_.ResourceType -Like 'Microsoft.Network/frontdoors'`
				-or $_.resourceType -like 'Microsoft.DataFactory/factories') }
	foreach ($kv in $kvs) {
		$DiagnosticSettingName = 'diag' + '-' + $kv.name
		
		$diags = Get-AzDiagnosticSetting -ResourceId $kv.ResourceId
		if ($diags.WorkspaceId -contains $WorkspaceId) {
			write-host 'dont do it'
		}
		else {
			write-host 'ok dooooo it for ' $kv.name
			#Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -WorkspaceId $WorkspaceId -EnableLog $true -Name $DiagnosticSettingName
		}
	}	
}
