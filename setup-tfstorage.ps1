# Variables
$resourceGroupName = "debtSolverTfRG"
$storageAccountName = "debtsolvertfsa" # Must be globally unique
$containerName = "debtsolvertfcontainer"
$location = "eastus" # Adjust if needed

# Create Resource Group (if it doesn't already exist)
az group create `
    --name $resourceGroupName `
    --location $location `
    --output table

# Create Storage Account
az storage account create `
    --name $storageAccountName `
    --resource-group $resourceGroupName `
    --location $location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --output table

# Get Storage Account Key
$storageAccountKey = az storage account keys list `
    --resource-group $resourceGroupName `
    --account-name $storageAccountName `
    --query "[0].value" `
    --output tsv

# Create Blob Container
az storage container create `
    --name $containerName `
    --account-name $storageAccountName `
    --account-key $storageAccountKey `
    --public-access off `
    --output table

Write-Host "Storage account and container successfully created."
Write-Host "Storage Account Name: $storageAccountName"
Write-Host "Container Name: $containerName"
Write-Host "Storage Account Key: $storageAccountKey"
