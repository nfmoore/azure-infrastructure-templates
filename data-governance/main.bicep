//********************************************************
// General Parameters
//********************************************************

@allowed([
  'poc'
  'secure'
])
@description('Deployment Mode')
param deploymentMode string = 'poc'

@description('Workload Identifier')
param workloadIdentifier string = substring(uniqueString(resourceGroup().id), 0, 6)

@description('Resource Instance')
param resourceInstance string = '001'

//********************************************************
// Resource Config Parameters
//********************************************************

//Purview Account Parameters
@description('Purview Account Name')
param purviewAccountName string = 'pview${workloadIdentifier}${resourceInstance}'

@description('Purview Managed Resource Group Name')
param purviewManagedRgName string = '${resourceGroup().name}-pview-mngd'

@description('Purview Location')
param purviewLocation string = resourceGroup().location

// //----------------------------------------------------------------------

//Key Vault Parameters
@description('Key Vault Name')
param keyVaultName string = 'kv${workloadIdentifier}${resourceInstance}'

@description('Key Vault Location')
param keyVaultLocation string = resourceGroup().location

//Storage Account Parameters
@description('Storage Account Name')
param storageAccountName string = 'st${workloadIdentifier}${resourceInstance}'

@description('Storage Account Location')
param storageAccountLocation string = resourceGroup().location

@description('Storage Account SKU')
param storageAccountSku string = 'Standard_LRS'

@description('Allow Shared Key Access')
param allowSharedKeyAccess bool = false

//********************************************************
// Shared Resources
//********************************************************

//********************************************************
// Modules
//********************************************************

//Deploy Purview Account
module m_PurviewDeploy 'modules/purview.bicep' = {
  name: 'PurviewDeploy'
  params: {
    deploymentMode: deploymentMode
    purviewAccountName: purviewAccountName
    purviewManagedRgName: purviewManagedRgName
    purviewLocation: purviewLocation
  }
}

// Deploy Key Vault

module m_KeyVaultDeploy 'modules/key-vault.bicep' = {
  name: 'KeyVaultDeploy'
  params: {
    deploymentMode: deploymentMode
    keyVaultLocation: keyVaultLocation
    keyVaultName: keyVaultName
    purviewIdentityPrincipalID: m_PurviewDeploy.outputs.purviewIdentityPrincipalID
  }
}

// Deploy Storage Account

module m_StorageAccountDeploy 'modules/storage.bicep' = {
  name: 'StorageAccountDeploy'
  params: {
    deploymentMode: deploymentMode
    storageAccountName: storageAccountName
    resourceLocation: storageAccountLocation
    allowSharedKeyAccess: allowSharedKeyAccess
    storageAccountSku: storageAccountSku
  }
}

//********************************************************
// RBAC Role Assignments
//********************************************************

//********************************************************
// Outputs
//********************************************************
