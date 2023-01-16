#######################################################################
#  Created by: Vipul Lende                                           #
######################################################################
$arrayData = @()

$resources = Get-AzResource  



foreach($resource in $resources)
{
$ResourceName = $resource.name 
$ResourceTag = $resource.Tags 
$ResourceType = $resource.Type
$ResourceGroup = $resource.ResourceGroupName
$ResourceID = $resource.Id

$Tagdata = ""

foreach($TagDictionary in $ResourceTag)
{
     foreach($Key in $TagDictionary.Keys)
     {
        $Tagdata += $Key + ":" + $($TagDictionary[$key]) + ","
     }    
}

$Report = " " | Select Resource_Name , Tags, Resource_Type, Resource_Group, ReID

$Report.Resource_Name = $ResourceName
$Report.Tags = $Tagdata.TrimEnd(",")
$Report.Resource_Type = $ResourceType
$Report.Resource_Group = $ResourceGroup
$report.ReID = $ResourceID
$arraydata += $Report

}

$arrayData


