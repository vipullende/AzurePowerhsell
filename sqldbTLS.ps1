$subs = Get-AzSubscription #| Where-Object Name -like 'production'
foreach ($sub in $subs) {
    select-AzSubscription -Subscription $sub.Name 
    $sqlServer += Get-AzSqlServer
}
    $sqlServer | select ServerName, MinimalTlsVersion
