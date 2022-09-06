
###########################################################################
#   This script is to Lock the VMs which are unloked for more than 1 day  #
#                                                                         #
###########################################################################
#   Created by: Vipul Lende                                               #
###########################################################################

#[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

$username = 'user'
$password = 'pass'

$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
Connect-AzAccount -Credential $creds


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
                New-AzResourceLock -LockName DeleteLock `
                    -LockLevel CanNotDelete `
                    -ResourceGroupName $vm.ResourceGroupName `
                    -ResourceName $vm.Name `
                    -ResourceType Microsoft.Network/virtualNetworks `
                    -Force
            }
            else {
                Write-Host $vm.Name 'dont Lock'
                $dontlock += $vm
            }

        }  
    }
}
