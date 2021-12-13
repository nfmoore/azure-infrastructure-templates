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
param purviewManagedResourceGroupName string = '${resourceGroup().name}-pview-mngd'

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
param storageAccountName string = 'diag${workloadIdentifier}${resourceInstance}'

@description('Storage Account Location')
param storageAccountLocation string = resourceGroup().location

@description('Storage Account SKU')
param storageAccountSKU string = 'Standard_LRS'

@description('Allow Shared Key Access')
param allowSharedKeyAccess bool = false

//Log Analytics Workspace Parameters
@description('Log Analytics Workspace Name')
param logAnalyticsWorkspaceName string = 'law${workloadIdentifier}${resourceInstance}'

@description('Log Analytics Workspace Location')
param logAnalyticsWorkspaceLocation string = resourceGroup().location

@description('Log Analytics Workspace SKU')
param logAnalyticsWorkspaceSKU string = 'PerGB2018'

@description('Log Analytics Workspace Daily Quota')
param logAnalyticsWorkspaceDailyQuota int = 1

@description('Log Analytics Workspace Retention Period')
param logAnalyticsWorkspaceRetentionPeriod int = 30

//********************************************************
// Resources
//********************************************************

//Deploy Purview Account
resource r_purviewAccount 'Microsoft.Purview/accounts@2020-12-01-preview' = {
  name: purviewAccountName
  location: purviewLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: (deploymentMode == 'secure') ? 'Disabled' : 'Enabled'
    managedResourceGroupName: purviewManagedResourceGroupName
  }
}

// Deploy Key Vault
resource r_keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: keyVaultLocation
  properties: {
    tenantId: subscription().tenantId
    enabledForTemplateDeployment: true
    enabledForDeployment: true
    enableSoftDelete: true
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: (deploymentMode == 'secure') ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
    // TODO: Access Policy to allow user to access secrets
    accessPolicies: [
      // Access Policy to allow Purview to Get and List Secrets
      // https://docs.microsoft.com/en-us/azure/purview/manage-credentials#grant-the-purview-managed-identity-access-to-your-azure-key-vault
      {
        objectId: r_purviewAccount.identity.principalId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Deploy Storage Account
resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: storageAccountLocation
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
    name: storageAccountSKU
  }
}

// Deploy Log Analytics Workspace
resource r_logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticsWorkspaceLocation
  properties: {
    retentionInDays: logAnalyticsWorkspaceRetentionPeriod
    sku: {
      name: logAnalyticsWorkspaceSKU
    }
    workspaceCapping: {
      dailyQuotaGb: logAnalyticsWorkspaceDailyQuota
    }
  }
}

//********************************************************
// RBAC Role Assignments
//********************************************************

//********************************************************
// Outputs
//********************************************************
