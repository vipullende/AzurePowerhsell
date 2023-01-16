
$WorkspaceId = 'workspace resource ID'

$subs = Get-AzSubscription | Where-Object Name -Like "non-prod"
foreach ($sub in $subs) {
	select-AzSubscription -Subscription $sub.Name   
	$kvs = Get-AzResource | Where-Object { ($_.ResourceType -Like 'Microsoft.Network/applicationGateways'`
	            -or $_.ResourceType -Like 'Microsoft.KeyVault/vaults'`
			    -or $_.ResourceType -like 'Microsoft.Network/virtualNetworks'`
				-or $_.ResourceType -Like 'Microsoft.Network/frontdoors'`
				-or $_.resourceType -like 'Microsoft.DataFactory/factories'`
				-or $_.resourceType -like 'Microsoft.ApiManagement/service'`
				-or $_.resourceType -like 'Microsoft.Sql/servers/databases'-and $_.Name -notlike '*master'`
				-or $_.resourceType -like 'Microsoft.Web/sites'`
				-or $_.resourceType -like 'Microsoft.Logic/workflows'`
				-or $_.resourceType -like 'Microsoft.ContainerService/ManagedClusters'`
				-or $_.resourceType -like 'Microsoft.Databricks/workspaces'`
				-or $_.resourceType -like 'Microsoft.Network/loadBalancers'`
				-or $_.resourceType -like 'Microsoft.NotificationHubs/namespaces'`
				-or $_.resourceType -like 'Microsoft.Network/virtualNetworkGateways'`
				-or $_.resourceType -like 'Microsoft.Web/serverfarms'`
				-or $_.resourceType -like 'Microsoft.DocumentDB/databaseAccounts'`
				-or $_.resourceType -like 'Microsoft.Network/expressRouteCircuits'`
				-or $_.resourceType -like 'Microsoft.EventHub/Namespaces'`
				-or $_.resourceType -like 'Microsoft.RecoveryServices/vaults') }
	foreach ($kv in $kvs) {
		$DiagnosticSettingName = 'diag' + '-' + $kv.ResourceId.split('/')[-1]
		
		 $diags = Get-AzDiagnosticSetting -ResourceId $kv.ResourceId
		 $diags.Name
		if ($diags.Name -contains "diag-aks-vnet-55820443" ) {
		# 	write-host 'dont do it'
		# }
		# else {
		# 	write-host 'ok dooooo it for ' $kv.name
		#Remove-AzDiagnosticSetting -ResourceId $kv.ResourceId  -Name 'diag-aks-vnet-30597224'
		#Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -WorkspaceId $WorkspaceId -EnableLog $true  -EnableMetrics $true -Name $DiagnosticSettingName

	
		}
	}	
}


