
$vmlist = Import-Csv -Path ".\list.csv"

foreach ($vm in $vmlist) {
    az vm run-command invoke -g $vm.MyResourceGroup -n $vm.MyVm --command-id RunShellScript --scripts "chmod 777 /etc/sudoers && cp /tmp/sudoers /etc/ chmod 440 /etc/sudoers"
}

#az vm run-command invoke -g $MyResourceGroup -n $MyVm --command-id RunShellScript --scripts "chmod 777 /etc/sudoers && cp /tmp/sudoers /etc/ chmod 440 /etc/sudoers"