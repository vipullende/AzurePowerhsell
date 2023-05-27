
$Data = @()
$subs = Get-AzSubscription
foreach ($sub in $subs) {
    Select-AzSubscription -subscription $sub.name
    $nsgs = Get-AzNetworkSecurityGroup
    foreach ($nsg in $nsgs){
        $Report = ' ' | Select 'NSG_Name', 'Subnet_name'
        $Report.NSG_Name = $nsg.Name
        $Report.Subnet_name = $nsg.Subnets.id #.split('/')[-1]
        $data += $Report
    }
}
$Data

