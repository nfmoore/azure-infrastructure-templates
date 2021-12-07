param deploymentMode string
param resourceLocation string

param azureMlWorkspaceName string
param azureMlStorageAccountName string
param azureMlAppInsightsName string
param azureMlContainerRegistryName string
param keyVaultId string
param synapseSparkPoolId string
param synapseSparkPoolName string
param synapseWorkspaceId string
param synapseWorkspaceName string
param synapseWorkspaceLocation string
param linkSynapseSparkPool bool

//Azure ML Storage Account
resource r_azureMlStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: azureMlStorageAccountName
  location: resourceLocation
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
  name: azureMlAppInsightsName
  location: resourceLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

//Azure ML Container Registry
//Premium tier is required for Private Link deployment: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-private-link#prerequisites
resource r_azureMlContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: azureMlContainerRegistryName
  location: resourceLocation
  sku: {
    name: (deploymentMode == 'secure') ? 'Premium' : 'Basic'
  }
  properties: {}
}

//Azure Machine Learning Workspace
resource r_azureMlWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-04-01' = {
  name: azureMlWorkspaceName
  location: resourceLocation
  sku: {
    name: 'basic'
    tier: 'basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: azureMlWorkspaceName
    keyVault: keyVaultId
    storageAccount: r_azureMlStorageAccount.id
    applicationInsights: r_azureMlAppInsights.id
    containerRegistry: r_azureMlContainerRegistry.id
  }
}

resource r_azureMlSynapseSparkCompute 'Microsoft.MachineLearningServices/workspaces/computes@2021-04-01' = if (linkSynapseSparkPool == true) {
  parent: r_azureMlWorkspace
  name: synapseSparkPoolName
  location: synapseWorkspaceLocation
  properties: {
    computeType: 'SynapseSpark'
    resourceId: synapseSparkPoolId
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
    linkedServiceResourceId: synapseWorkspaceId
  }
}

output azureMlWorkspaceIdentityPrincipalId string = r_azureMlWorkspace.identity.principalId
output azureMlSynapseLinkedServicePrincipalId string = r_azureMlSynapseLinkedService.identity.principalId
output azureMlWorkspaceId string = r_azureMlWorkspace.id
