$resourceGroup = "rg_Production"
$storageAccountName = "stgproduction"
#$containerName = "archive"
$Report = @()

$StorageContainerUsageReport =@()



# get a reference to the  account and the context
$storageAccount = Get-AzStorageAccount `
  -ResourceGroupName $resourceGroup `
  -Name $storageAccountName
$ctx = $storageAccount.Context 
$containers = Get-AzStorageContainer  -Context $ctx
foreach ($container in $containers) {
 
  # get a list of all of the blobs in the container 
  $listOfBLobs = Get-AzStorageBlob -Container $container.Name -Context $ctx 
  # zero out our total
  $length = 0

  # this loops through the list of blobs and retrieves the length for each blob
  #   and adds it to the total
  $listOfBlobs | ForEach-Object { $length = $length + $_.Length }

  # output the blobs and their sizes and the total 
  Write-Host "List of Blobs and their size (length)"
  Write-Host " " 
  #$listOfBlobs | select Name, Length 
  Write-Host " "
  Write-Host "Total Length = " $length +  $container.Name
  $Report = " " | Select "Storage container Name", "Used Capacity in bytes", "Used Capacity in GB"
  $Report."Storage container Name" = $container.Name
  $Report."Used Capacity in bytes" = $length

  $Report."Used Capacity in GB"= [math]::Round($length / 1Gb, 2)
  $StorageContainerUsageReport += $Report

}
$StorageContainerUsageReport | Export-Csv -NoTypeInformation ./"$storageAccountName"_Report.csv

