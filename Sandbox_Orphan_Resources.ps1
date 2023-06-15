# Set the Azure subscription
Set-AzContext -SubscriptionId "a96e49c9-c03d-4ead-adc8-069ffcbc3b29"

# Get all resources in the subscription
$resources = Get-AzResource

# Create an array to store the resource details
$resourceDetails = @()

# Iterate through each resource
$all=((Invoke-AzRestMethod -Path "/subscriptions/$subscriptionId/resources?api-version=2022-05-01&`$expand=createdTime&$select=name,type,createdTime" -Method GET).Content|ConvertFrom-Json).value
foreach ($resource in $all) {
    # Get resource details
    $resourceName = $resource.Name
    $resourceType = $resource.Type
    $resourceCreationDate = $resource.CreatedTime

    if ($resourceCreationDate -ne $null) {
        $resourceCreationDate = $resourceCreationDate.ToString('yyyy-MM-dd HH:mm:ss')
    }

    else {
    $resourceCreationDate = "NA"
    }

    # Create a custom object with resource details
    $resourceObject = [PSCustomObject]@{
        'Resource Name' = $resourceName
        'Resource Type' = $resourceType
        'Resource Creation Date' = $resourceCreationDate
    }

    # Add the resource object to the array
    $resourceDetails += $resourceObject
}

# Export the resource details as a CSV file
$resourceDetails | Export-Csv -Path "ResourceDetails.csv" -NoTypeInformation

# Set the storage account details
#$storageAccountName = "stafortestingscript"
$storageAccountName = "stgpdigeastus001"
$storageContainerName = "allresourcesoutput"
$storageAccountKey = "ywsCfg5NuHE/2EmxjRttQxvcDySuQdZwto2EurpTabGBtmNsMWekQ/iMmqdyK+hfhND8goU/05I43lM2o4s0RA=="
$localFilePath = "ResourceDetails.csv"
$storageBlobName = "resources.csv"

# Create the storage context
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Upload the CSV file to the specified storage account and container
Set-AzStorageBlobContent -Context $storageContext -Container $storageContainerName -File $localFilePath -Blob $storageBlobName -Force

# Output a message with the storage account URL
$storageAccountUrl = "https://stgpdigeastus001.blob.core.windows.net/allresourcesoutput/resources.csv"
Write-Output "CSV file uploaded at Path: $storageAccountUrl"

# Delete the local CSV file after it's uploaded
Remove-Item -Path $localFilePath -Force

Write-Output "All Set.. You are good to go..."