#######################################################################
#   This script is to get the list routes and route Tables            #
#######################################################################
#  Created by: Vipul Lende                                           #
######################################################################

$data = @()
$routes = @()
$arraydata = @()
$allsubnetdata = @()
$subs = Get-AzSubscription
foreach ($sub in $subs) {
    Select-AzSubscription -subscription $sub.name
    $routeTables = Get-AzRouteTable
    foreach ($routeTable in $routeTables) {
        $routes = Get-AzRouteTable -ResourceGroupName $routeTable.ResourceGroupName -name $routeTable.name
        foreach ($route in $routes.Routes ) {
            $data = " " | select "Sub_Name", "ResourceGroupName", "Route_Table_Name", "route_name", "NextHopType", "NextHopIpAddress", "AddressPrefix"
            $data.Sub_Name = $sub.Name
            $data.Route_Table_Name = $routeTable.Name
            $data.ResourceGroupName = $routeTable.ResourceGroupName
            $data.route_name = $route.Name
            $data.NextHopType = $route.NextHopType
            $data.NextHopIpAddress = $route.NextHopIpAddress
            $data.AddressPrefix = $route.AddressPrefix
            #            $data.Subnet = $routes.Subnets.id
        
            $arraydata += $data

        }
        foreach ($subnet in $routes.Subnets) {
            $subnetdata = " " | select "Sub_Name", "ResourceGroupName", "Route_Table_Name", "Subnet"
            $subnetdata.Sub_Name = $sub.Name
            $subnetdata.Route_Table_Name = $routeTable.Name
            $subnetdata.ResourceGroupName = $routeTable.ResourceGroupName
            $subnetdata.Subnet = $subnet.id.Split("/")[-1]
            #           $subnet.id.Split("/")[-1]

            $allsubnetdata += $subnetdata
        }
    
    }

}
$arraydata 
$arraydata  | Export-Csv -NoTypeInformation .\routeInfo.csv
$allsubnetdata
$allsubnetdata | Export-Csv -NoTypeInformation .\routeWithSubnet.csv

