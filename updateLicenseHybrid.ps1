###########################################################################
# This script is to set Azure Azure Hybrid Benefit for windows and Suse VM#
#                                                                         #
###########################################################################
#   Created by: Vipul Lende                                               #
###########################################################################
$subs = Get-AzSubscription | Where-Object Name -notlike "Access"
foreach ($sub in $subs){
    Select-AzSubscription -Subscription $sub
    $lvms = get-azvm | where {( $_.StorageProfile.OsDisk.OsType -like "Linux")}`
    | where{( $_.StorageProfile.imageReference.Publisher -like "suse")}| where {( $_.LicenseType -notlike "SLES_BYOS" )}

    if($lvms.count -gt 0){
        foreach($lvm in $lvms){
            #az vm update -g $vm.myResourceGroup -n $vm.Name --license-type SLES_BYOS
            $vm.LicenseType = "SLES_BYOS"
            Update-AzVM -ResourceGroupName $lvm.ResourceGroupName -VM $lvm
        }
    }else {
        Write-Output "Nothing to Update for 'Azure Azure Hybrid Benefit updated'"
    }
    #####################"Windows"###################

    $wvms = get-azvm | where {( $_.StorageProfile.OsDisk.OsType -like "windows")}| where {( $_.LicenseType -notlike "Windows_Server" )}

    if($wvms.count -gt 0){
        foreach($wvm in $wvms){
            #az vm update -g $vm.myResourceGroup -n $vm.Name --license-type SLES_BYOS
            $wvm.LicenseType = "Windows_Server"
            Update-AzVM -ResourceGroupName $wvm.ResourceGroupName -VM $wvm
        }
    }else {
        Write-Output "Hurry Nothing to Update for 'Azure Hybrid Benefit'"
    }

    ##################SQL virtual machine
    $svms = Get-AzSqlVM| where {( $_.LicenseType -notlike "AHUB" )}

    if($svms.count -gt 0){
        foreach($svm in $svms){
            #az vm update -g $vm.myResourceGroup -n $vm.Name --license-type SLES_BYOS
            $svm.LicenseType = "AHUB"
            Update-AzVM -ResourceGroupName $svm.ResourceGroupName -VM $svm
        }
    }else {
        Write-Output "Hurry Nothing to Update for 'Azure Hybrid Benefit'"
    }

}