Select-AzSubscription -Subscription "production"
$sqlservers = Get-AzSqlServer

foreach($sqlserver in $sqlservers){
    $sqldatabases = Get-AzSqlDatabase -ServerName $sqlserver.ServerName -ResourceGroupName $sqlserver.ResourceGroupName | where DatabaseName -NotLike "master"
    foreach($sqldatabase in $sqldatabases){
       Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $sqlserver.ResourceGroupName  -ServerName $sqlserver.ServerName -DatabaseName $sqldatabase.DatabaseName -RetentionDays 30
    }
    $sqlserver.ServerName

}