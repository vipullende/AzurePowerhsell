$rgs = Get-AzResourceGroup
foreach($rg in $rgs)
{
    $rg.tag
}