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
param synapseSparkPoolName string = 'SparkPool001'

// //----------------------------------------------------------------------

//Key Vault Parameters
@description('Key Vault Name')
param keyVaultName string = 'kv${workloadIdentifier}${resourceInstance}'

@description('Key Vault Resource Group')
param keyVaultResourceGroupName string = '${resourceGroup().name}'

//********************************************************
// Variables
//********************************************************

var azureRbacStorageBlobDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader Role
var azureRbacContributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor

//********************************************************
// Shared Resources
//********************************************************

// Key Vault
resource r_keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
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
resource r_dataLakeStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: dataLakeAccountName
  scope: resourceGroup(dataLakeAccountResourceGroupName)
}

// Access Policy to allow Azure ML to Get and List Secrets
module m_azureMlKeyVaultAccessPolicy './modules/key-vault-access-policy.bicep' = {
  name: 'AzureMLKeyVaultAccessPolicyDeploy'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    principalId: m_azureMl.outputs.azureMlWorkspaceIdentityPrincipalId
  }
}

//********************************************************
// Modules
//********************************************************

// Deploy AML Services
module m_azureMl 'modules/azureml.bicep' = {
  name: 'AMLDeploy'
  params: {
    deploymentMode: deploymentMode
    resourceLocation: azureMLWorkspaceLocation
    azureMLWorkspaceName: azureMLWorkspaceName
    azureMLStorageAccountName: azureMLStorageAccountName
    azureMLAppInsightsName: azureMLAppInsightsName
    azureMLContainerRegistryName: azureMLContainerRegistryName
    keyVaultId: r_keyVault.id
    synapseSparkPoolId: (linkSynapseSparkPool == true) ? r_sparkPool.id : ''
    synapseSparkPoolName: (linkSynapseSparkPool == true) ? synapseSparkPoolName : ''
    synapseWorkspaceId: (linkSynapseSparkPool == true) ? r_synapseWorkspace.id : ''
    synapseWorkspaceName: (linkSynapseSparkPool == true) ? synapseWorkspaceName : ''
    synapseWorkspaceLocation: (linkSynapseSparkPool == true) ? synapseWorkspaceLocation : ''
    linkSynapseSparkPool: linkSynapseSparkPool
  }
}

//********************************************************
// RBAC Role Assignments
//********************************************************

// Azure Synaspe MSI needs to have Contributor permissions in the Azure ML workspace.
// https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/quickstart-integrate-azure-machine-learning#give-msi-permission-to-the-azure-ml-workspace
module m_synapseAzureMLContributorRoleAssignment './modules/role-assignment.bicep' = if (linkSynapseSparkPool == true) {
  name: 'SynapseAzureMLContributorRoleAssignmentDeploy'
  scope: resourceGroup()
  params: {
    name: guid(synapseWorkspaceName, azureMLWorkspaceName, 'Contributor')
    roleId: azureRbacContributorRoleId
    principalId: r_synapseWorkspace.identity.principalId
  }
  dependsOn: [
    m_azureMl
  ]
}

// Assign Storage Blob Data Reader Role to Azure ML Synapse Linked Service MSI in the Data Lake Account as per https://docs.microsoft.com/en-us/azure/machine-learning/how-to-identity-based-data-access
module m_azureMlSynapseLinkedServiceStorageBlobDataReaderRoleAssignment './modules/role-assignment.bicep' = if (linkDataLakeAccount == true && linkSynapseSparkPool == true) {
  name: 'SynapseLinkedServiceStorageBlobDataReaderRoleAssignmentDeploy'
  scope: resourceGroup(dataLakeAccountResourceGroupName)
  params: {
    name: guid(r_dataLakeStorageAccount.name, azureMLWorkspaceName, 'Storage Blob Data Reader')
    roleId: azureRbacStorageBlobDataReaderRoleId
    principalId: m_azureMl.outputs.azureMlSynapseLinkedServicePrincipalId
  }
}

//********************************************************
// Outputs
//********************************************************
