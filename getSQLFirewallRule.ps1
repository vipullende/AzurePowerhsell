$firewallRules = @()
$subs = Get-AzSubscription #| Where-Object Name -like 'production'

foreach ($sub in $subs) {
    select-AzSubscription -Subscription $sub.Name
    $sqlservers = Get-AzSqlServer
    foreach ($sqlserver in $sqlservers) {
        $rules = Get-AzSqlServerFirewallRule  -ResourceGroupName $sqlserver.ResourceGroupName -ServerName $sqlserver.ServerName
        $firewallRules += $rules
    }
}
$firewallRules |    Export-Csv -NoTypeInformation ./SQLServerFirewallRules.csv