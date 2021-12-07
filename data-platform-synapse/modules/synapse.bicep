param deploymentMode string
param resourceLocation string

param deploySynapseDedicatedSqlPool bool

param dataLakeAccountName string
param allowSharedKeyAccess bool
param dataLakeAccountSku string
param dataLakeBronzeZoneName string
param dataLakeSilverZoneName string
param dataLakeGoldZoneName string
param dataLakeSandboxZoneName string
param dataLakeStagingZoneName string
param synapseDefaultContainerName string

param synapseWorkspaceName string
param synapseSqlAdminUserName string
@secure()
param synapseSqlAdminPassword string
param synapseManagedRgName string
param synapseDedicatedSQLPoolName string
param synapseSQLPoolSku string
param synapseSparkPoolName string
param synapseSparkPoolNodeSize string
param synapseSparkPoolMinNodeCount int
param synapseSparkPoolMaxNodeCount int

param purviewAccountID string

var storageEnvironmentDNS = environment().suffixes.storage
var dataLakeStorageAccountUrl = 'https://${dataLakeAccountName}.dfs.${storageEnvironmentDNS}'
var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor Role

// Data Lake Storage Account
resource r_dataLakeStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: dataLakeAccountName
  location: resourceLocation
  properties: {
    isHnsEnabled: true
    accessTier: 'Hot'
    allowBlobPublicAccess: (deploymentMode != 'secure')
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: allowSharedKeyAccess
    networkAcls: {
      defaultAction: (deploymentMode == 'secure') ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
      resourceAccessRules: [
        {
          tenantId: subscription().tenantId
          resourceId: r_synapseWorkspace.id
        }
      ]
    }
  }
  kind: 'StorageV2'
  sku: {
    name: dataLakeAccountSku
  }
}

var privateContainerNames = [
  dataLakeBronzeZoneName
  dataLakeSilverZoneName
  dataLakeGoldZoneName
  dataLakeSandboxZoneName
  dataLakeStagingZoneName
  synapseDefaultContainerName
]

resource r_dataLakePrivateContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = [for containerName in privateContainerNames: {
  name: '${r_dataLakeStorageAccount.name}/default/${containerName}'
}]

//Synapse Workspace
resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: resourceLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: dataLakeStorageAccountUrl
      filesystem: synapseDefaultContainerName
    }
    sqlAdministratorLogin: synapseSqlAdminUserName
    sqlAdministratorLoginPassword: synapseSqlAdminPassword
    managedResourceGroupName: synapseManagedRgName
    managedVirtualNetwork: (deploymentMode == 'secure') ? 'default' : ''
    managedVirtualNetworkSettings: (deploymentMode == 'secure') ? {
      preventDataExfiltration: true
    } : null
    purviewConfiguration: {
      purviewResourceId: purviewAccountID
    }
  }

  // Dedicated SQL Pool
  resource r_sqlPool 'sqlPools' = if (deploySynapseDedicatedSqlPool == true) {
    name: synapseDedicatedSQLPoolName
    location: resourceLocation
    sku: {
      name: synapseSQLPoolSku
    }
    properties: {
      createMode: 'Default'
      collation: 'SQL_Latin1_General_CP1_CI_AS'
    }
  }

  // Default Firewall Rules - Allow All Traffic
  resource r_synapseWorkspaceFirewallAllowAll 'firewallRules' = if (deploymentMode == 'default') {
    name: 'AllowAllNetworks'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }

  // Firewall Allow Azure Sevices
  // Required for Post-Deployment Scripts
  resource r_synapseWorkspaceFirewallAllowAzure 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }

  // Set Synapse MSI as SQL Admin
  resource r_managedIdentitySqlControlSettings 'managedIdentitySqlControlSettings' = {
    name: 'default'
    properties: {
      grantSqlControlToManagedIdentity: {
        desiredState: 'Enabled'
      }
    }
  }

  // Spark Pool
  resource r_sparkPool 'bigDataPools' = {
    name: synapseSparkPoolName
    location: resourceLocation
    properties: {
      autoPause: {
        enabled: true
        delayInMinutes: 15
      }
      nodeSize: synapseSparkPoolNodeSize
      nodeSizeFamily: 'MemoryOptimized'
      sparkVersion: '3.1'
      autoScale: {
        enabled: true
        minNodeCount: synapseSparkPoolMinNodeCount
        maxNodeCount: synapseSparkPoolMaxNodeCount
      }
      dynamicExecutorAllocation: {
        enabled: true
      }
    }
  }
}

// Synapse Workspace Role Assignment as Blob Data Contributor Role in the Data Lake Storage Account
// https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(r_synapseWorkspace.name, r_dataLakeStorageAccount.name)
  scope: r_dataLakeStorageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: r_synapseWorkspace.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output dataLakeStorageAccountId string = r_dataLakeStorageAccount.id
output dataLakeStorageAccountName string = r_dataLakeStorageAccount.name
output synapseWorkspaceId string = r_synapseWorkspace.id
output synapseWorkspaceName string = r_synapseWorkspace.name
output synapseSQLDedicatedEndpoint string = r_synapseWorkspace.properties.connectivityEndpoints.sql
output synapseSQLServerlessEndpoint string = r_synapseWorkspace.properties.connectivityEndpoints.sqlOnDemand
output synapseWorkspaceSparkId string = r_synapseWorkspace::r_sparkPool.id
output synapseWorkspaceIdentityPrincipalId string = r_synapseWorkspace.identity.principalId
