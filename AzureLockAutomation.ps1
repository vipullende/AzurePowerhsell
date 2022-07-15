
###########################################################################
#   This script is to Lock the VMs which are unloked for more than 1 day  #
#                                                                         #
###########################################################################
#   Created by: Vipul Lende                                               #
###########################################################################



$AllVMs = @()
$DaysAgo = 1
$dontlock = @()
$lockvms = @()
$logs = @()
$subscriptions = @()
$VM = @()
$tobeunlokedVM = @()
$logs = @()
$log = @()
#$error.Clear()
#Remove-Variable * -ErrorAction SilentlyContinue
$subscriptions = Get-AzSubscription | Where-Object Name -notlike Access*
foreach ($Sub in $subscriptions) {
    Select-AzSubscription -Subscription $sub.Name  
    $AllVMs = Get-AzVM | Where-Object ResourceGroupName -notlike DATABRICKS* 
    foreach ($VM in $AllVMs) {
        $lock = Get-AzResourceLock  -ResourceType 'Microsoft.Compute/virtualMachines' -ResourceGroupName $vm.ResourceGroupName  -ResourceName $VM.Name
        if ($lock) {
            # write-host $VM.Name "is locked"
        }
        else {
            Write-Host $vm.Name ' is NOT locked'  
            $tobeunlokedVM += $VM
            $logs = Get-AzActivityLog -ResourceId $vm.Id -StartTime (get-date).AddDays(-$DaysAgo) `
            | Where-Object { $_.OperationName.value -eq 'Microsoft.Authorization/locks/delete' -and ($_.Status.Value -eq 'Succeeded') }
            $log.OperationName
            if ($null -eq $logs ) {
                Write-Host $VM.Name 'lock today'
                $lockvms += $vm 
            }
            else {
                Write-Host $vm.Name 'dont Lock'
                $dontlock += $vm
            }

        }  
    }
}

# Get-AzResourceLock  -ResourceType "Microsoft.Compute/virtualMachines" -ResourceGroupName rg_prmcld_performance  -ResourceName allpcltest001
$logs = Get-AzActivityLog -ResourceId /subscriptions/759b9007-97f8-4a5c-abff-224a1c0b26f1/resourceGroups/rg_prmcld_performance/providers/Microsoft.Compute/virtualMachines/allpcltest001 -StartTime (get-date).AddDays(-$DaysAgo) `
| Where-Object { $_.OperationName.value -eq 'Microsoft.Authorization/locks/delete' -and ($_.Status.Value -eq 'Succeeded') }

# $logs.OperationName