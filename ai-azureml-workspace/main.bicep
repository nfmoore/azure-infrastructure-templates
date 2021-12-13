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

param linkSynapseSparkPool bool = true // Controls the creation of Synapse Spark Pool Linked Service
param linkDataLakeAccount bool = true // Controls the creation of Blob Data Reader Role for AML

//********************************************************
// Resource Config Parameters
//********************************************************

//Azure Machine Learning Parameters
@description('Azure Machine Learning Workspace Name')
param azureMLWorkspaceName string = 'mlw${workloadIdentifier}${resourceInstance}'

@description('Azure Machine Learning Workspace Location')
param azureMLWorkspaceLocation string = resourceGroup().location

@description('Azure Machine Learning Storage Account Name')
param azureMLStorageAccountName string = 'st${workloadIdentifier}${resourceInstance}'

@description('Azure Machine Learning Application Insights Name')
param azureMLAppInsightsName string = 'appi${workloadIdentifier}${resourceInstance}'

@description('Azure Machine Learning Container Registry Name')
param azureMLContainerRegistryName string = 'cr${workloadIdentifier}${resourceInstance}'

//----------------------------------------------------------------------

//Data Lake Parameters
@description('Data Lake Storage Account Name')
param dataLakeAccountName string = 'st${workloadIdentifier}${resourceInstance}'

@description('Data Lake Resource Group')
param dataLakeAccountResourceGroupName string = '${resourceGroup().name}'

//----------------------------------------------------------------------

//Synapse Workspace Parameters
@description('Synapse Workspace Name')
param synapseWorkspaceName string = 'syn${workloadIdentifier}${resourceInstance}'

@description('Synapse Workspace Resource Group')
param synapseWorkspaceResourceGroupName string = '${resourceGroup().name}'

@description('Synapse Workspace Resource Group')
param synapseWorkspaceLocation string = '${resourceGroup().location}'

@description('Spark Pool Name')
param synapseSparkPoolName string = 'SparkPool01'

// //----------------------------------------------------------------------

//Key Vault Parameters
@description('Use Existing Key Vault')
param useExistingKeyVault bool = true

@description('Key Vault Name')
param keyVaultName string = 'kv${workloadIdentifier}${resourceInstance}'

@description('Key Vault Resource Group')
param keyVaultResourceGroupName string = '${resourceGroup().name}'

@description('Key Vault Location')
param keyVaultLocation string = resourceGroup().location

//********************************************************
// Variables
//********************************************************

var azureRbacStorageBlobDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader Role
var azureRbacContributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor

//********************************************************
// Resources
//********************************************************

// Key Vault
resource r_keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = if (useExistingKeyVault == true) {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}

resource r_newKeyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = if (useExistingKeyVault == false) {
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
  }
}

// Synapse Workspace
resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-03-01' existing = {
  name: synapseWorkspaceName
  scope: resourceGroup(synapseWorkspaceResourceGroupName)
}

// Synapse Workspace Spark Pool
resource r_sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-03-01' existing = {
  parent: r_synapseWorkspace
  name: synapseSparkPoolName
}

// Data Lake
resource r_dataLakeStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = if (linkDataLakeAccount == true) {
  name: dataLakeAccountName
  scope: resourceGroup(dataLakeAccountResourceGroupName)
}

// Access Policy to allow Azure ML to Get and List Secrets
resource r_azureMlKeyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: r_azureMlWorkspace.identity.principalId
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

//Deploy AML Services

//Azure ML Storage Account
resource r_azureMlStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: azureMLStorageAccountName
  location: azureMLWorkspaceLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

//Azure ML Application Insights
resource r_azureMlAppInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: azureMLAppInsightsName
  location: azureMLWorkspaceLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

//Azure ML Container Registry
//Premium tier is required for Private Link deployment: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-private-link#prerequisites
resource r_azureMlContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: azureMLContainerRegistryName
  location: azureMLWorkspaceLocation
  sku: {
    name: (deploymentMode == 'secure') ? 'Premium' : 'Basic'
  }
  properties: {}
}

//Azure Machine Learning Workspace
resource r_azureMlWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-04-01' = {
  name: azureMLWorkspaceName
  location: azureMLWorkspaceLocation
  sku: {
    name: 'basic'
    tier: 'basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: azureMLWorkspaceName
    keyVault: (useExistingKeyVault == true) ? r_keyVault.id : r_newKeyVault.id
    storageAccount: r_azureMlStorageAccount.id
    applicationInsights: r_azureMlAppInsights.id
    containerRegistry: r_azureMlContainerRegistry.id
  }
}

//Azure Machine Learning Linked Services
resource r_azureMlSynapseSparkCompute 'Microsoft.MachineLearningServices/workspaces/computes@2021-04-01' = if (linkSynapseSparkPool == true) {
  parent: r_azureMlWorkspace
  name: synapseSparkPoolName
  location: synapseWorkspaceLocation
  properties: {
    computeType: 'SynapseSpark'
    resourceId: (linkSynapseSparkPool == true) ? r_sparkPool.id : ''
  }
}

resource r_azureMlSynapseLinkedService 'Microsoft.MachineLearningServices/workspaces/linkedServices@2020-09-01-preview' = if (linkSynapseSparkPool == true) {
  parent: r_azureMlWorkspace
  name: synapseWorkspaceName
  location: synapseWorkspaceLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    linkedServiceResourceId: (linkSynapseSparkPool == true) ? r_synapseWorkspace.id : ''
  }
}

//********************************************************
// RBAC Role Assignments
//********************************************************

// Azure Synaspe MSI needs to have Contributor permissions in the Azure ML workspace.
// https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/quickstart-integrate-azure-machine-learning#give-msi-permission-to-the-azure-ml-workspace
resource r_synapseAzureMLContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (linkSynapseSparkPool == true) {
  name: guid(synapseWorkspaceName, azureMLWorkspaceName, 'Contributor')
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRbacContributorRoleId)
    principalId: r_synapseWorkspace.identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    r_azureMlWorkspace
  ]
}

// Assign Storage Blob Data Reader Role to Azure ML Synapse Linked Service MSI in the Data Lake Account as per https://docs.microsoft.com/en-us/azure/machine-learning/how-to-identity-based-data-access
resource r_azureMlSynapseLinkedServiceStorageBlobDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (linkDataLakeAccount == true && linkSynapseSparkPool == true) {
  name: 'SynapseLinkedServiceStorageBlobDataReaderRoleAssignmentDeploy'
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRbacStorageBlobDataReaderRoleId)
    principalId: r_azureMlSynapseLinkedService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//********************************************************
// Outputs
//********************************************************
