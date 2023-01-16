$AllVMs = Get-AzVM | Where-Object ResourceGroupName -notlike DATABRICKS* 
    foreach ($VM in $AllVMs) {
        $lock = Get-AzResourceLock  -ResourceType 'Microsoft.Compute/virtualMachines' -ResourceGroupName $vm.ResourceGroupName  -ResourceName $VM.Name
        if ($lock) {
            # Remove-AzResourceLock -LockName DeleteLock `
            # -ResourceGroupName $vm.ResourceGroupName `
            # -ResourceType 'Microsoft.Compute/virtualMachines'
            # -ResourceName $vm.Id

            Remove-AzResourceLock -LockName 'DeleteLock' -ResourceGroupName $vm.ResourceGroupName -ResourceName $vm.Id  -ResourceType 'Microsoft.Compute/virtualMachines' -Force
        }
    }

    