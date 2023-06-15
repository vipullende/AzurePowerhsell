 
$data = @()  
$Report =@()
$list_subscription = Get-AzSubscription  |  Where-Object Name -notlike Access* 
foreach($subscription in $list_subscription){
    select-AzSubscription -Subscription $subscription
    $rgs = Get-AzResourceGroup  
foreach($rg in $rgs){
    $data = " " | Select ResourceGroupName , ApplicationNameTag, Subscription
    $data.ResourceGroupName = $rg.ResourceGroupName
    $data.ApplicationNameTag = $rg.Tags.ApplicationName 
    $data.Subscription = $subscription.name
    $data
    $Report += $data
}
}
$Report | Export-Csv -NoTypeInformation RG_ApplicationNameTag.csv