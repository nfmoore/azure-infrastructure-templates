param storageAccountName string
param resourceLocation string

param deploymentMode string
param allowSharedKeyAccess bool
param storageAccountSku string

// Data Lake Storage Account
resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: resourceLocation
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: (deploymentMode != 'secure')
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: allowSharedKeyAccess
    networkAcls: {
      defaultAction: (deploymentMode == 'secure') ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
  }
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
}

output storageAccountID string = r_storageAccount.id
output storageAccountName string = r_storageAccount.name
