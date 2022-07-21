
$WorkspaceId = 'resource ID'

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
