$rgs = Get-AzResourceGroup
foreach($rg in $rgs)
{
    $rg.TagsTable | where ({$_.name -Like "ApplicationName"})
}