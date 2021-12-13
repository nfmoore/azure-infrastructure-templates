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

@description('Controls the deployment of Azure Purview')
param deployPurview bool = true

@description('Controls the creation of Synapse SQL Pool')
param deploySynapseDedicatedSQLPool bool = false

@description('Controls the deployment of SQL Database')
param deployIntegrationMetadataDatabase bool = true

//********************************************************
// Resource Config Parameters
//********************************************************

//Data Lake Parameters
@description('Data Lake Storage Account Name')
param dataLakeAccountName string = 'st${workloadIdentifier}${resourceInstance}'

@description('Data Lake Storage Account SKU')
param dataLakeAccountSKU string = 'Standard_LRS'

@description('Allow Shared Key Access')
param allowSharedKeyAccess bool = false

@description('Data Lake Bronze Zone Container Name')
param dataLakeBronzeZoneName string = 'raw'

@description('Data Lake Silver Zone Container Name')
param dataLakeSilverZoneName string = 'trusted'

@description('Data Lake Gold Zone Container Name')
param dataLakeGoldZoneName string = 'curated'

@description('Data Lake Sandbox Zone Container Name')
param dataLakeSandboxZoneName string = 'sandbox'

@description('Data Lake Staging Zone Container Name')
param dataLakeStagingZoneName string = 'staging'

@description('Synapse Default Container Name')
param synapseDefaultContainerName string = 'system'
//----------------------------------------------------------------------

//Synapse Workspace Parameters
@description('Synapse Workspace Name')
param synapseWorkspaceName string = 'syn${workloadIdentifier}${resourceInstance}'

@description('Synapse Location')
param synapseLocation string = resourceGroup().location

@description('SQL Pool Admin User Name')
param synapseSQLAdminUserName string = 'azsynapseadmin'

@description('SQL Pool Admin User Name')
param synapseSQLAdminPassword string = 'synapse-sql-admin-password'

@description('Synapse Managed Resource Group Name')
param synapseManagedResourceGroupName string = '${resourceGroup().name}-syn-mngd'

@description('SQL Pool Name')
param synapseDedicatedSQLPoolName string = 'SqlPool01'

@description('SQL Pool SKU')
param synapseSQLPoolSKU string = 'DW100c'

@description('Spark Pool Name')
param synapseSparkPoolName string = 'SparkPool01'

@description('Spark Node Size')
param synapseSparkPoolNodeSize string = 'Small'

@description('Spark Min Node Count')
param synapseSparkPoolMinNodeCount int = 2

@description('Spark Max Node Count')
param synapseSparkPoolMaxNodeCount int = 12
//----------------------------------------------------------------------

//SQL DB Account Parameters

@description('SQL Server Location')
param SQLLocation string = resourceGroup().location

@description('SQL Server Name')
param SQLServerName string = 'sql${workloadIdentifier}${resourceInstance}'

@description('SQL DBAdmin User Name')
param SQLServerAdminUserName string = 'azsqladmin'

@description('SQL DB Admin User Name')
param SQLServerAdminPassword string = 'sql-server-admin-password'

@description('SQL Database Name')
param SQLDatabaseName string = 'IntegrationMetadata'

@description('SQL Database SKU')
param SQLDatabaseSKU object = {
  name: 'GP_S_Gen5'
  tier: 'GeneralPurpose'
  family: 'Gen5'
  capacity: 1
}

@description('SQL Database Auto Pause Delay')
param SQLDatabaseAutoPauseDelay int = 60

@description('SQL Min Capacity')
param SQLDatabaseMinCapacity int = 1
//----------------------------------------------------------------------

//Purview Account Parameters
@description('Purview Account Name')
param purviewAccountName string = 'pview${workloadIdentifier}${resourceInstance}'

@description('Purview Resource Group')
param purviewResourceGroupName string = '${resourceGroup().name}'

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
// var azureRbacPurviewDataCuratorRoleId = '8a3c2885-9b38-4fd2-9d99-91af537c1347' // Purview Data Curator Role

//********************************************************
// Resources
//********************************************************

// Purview
resource r_purviewAccount 'Microsoft.Purview/accounts@2021-07-01' existing = {
  name: purviewAccountName
  scope: resourceGroup(purviewResourceGroupName)
}

// Key Vault
resource r_keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}

// Access Policy to allow Synapse to Get and List Secrets
//https://docs.microsoft.com/en-us/azure/data-factory/how-to-use-azure-key-vault-secrets-pipeline-activities
resource r_keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: m_synapseWorkspace.outputs.synapseWorkspaceIdentityPrincipalId
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

//********************************************************
// Modules
//********************************************************

// Deploy Synapse Workspace
module m_synapseWorkspace 'modules/synapse.bicep' = {
  name: 'SynapseDeploy'
  params: {
    deploymentMode: deploymentMode
    resourceLocation: synapseLocation
    allowSharedKeyAccess: allowSharedKeyAccess
    deploySynapseDedicatedSqlPool: deploySynapseDedicatedSQLPool
    dataLakeAccountName: dataLakeAccountName
    dataLakeAccountSku: dataLakeAccountSKU
    dataLakeBronzeZoneName: dataLakeBronzeZoneName
    dataLakeSilverZoneName: dataLakeSilverZoneName
    dataLakeGoldZoneName: dataLakeGoldZoneName
    dataLakeSandboxZoneName: dataLakeSandboxZoneName
    dataLakeStagingZoneName: dataLakeStagingZoneName
    synapseDefaultContainerName: synapseDefaultContainerName
    purviewAccountId: (deployPurview == true) ? r_purviewAccount.id : ''
    synapseDedicatedSqlPoolName: synapseDedicatedSQLPoolName
    synapseManagedResourceGroupName: synapseManagedResourceGroupName
    synapseSparkPoolMaxNodeCount: synapseSparkPoolMaxNodeCount
    synapseSparkPoolMinNodeCount: synapseSparkPoolMinNodeCount
    synapseSparkPoolName: synapseSparkPoolName
    synapseSparkPoolNodeSize: synapseSparkPoolNodeSize
    synapseSqlAdminPassword: r_keyVault.getSecret(synapseSQLAdminPassword)
    synapseSqlAdminUserName: synapseSQLAdminUserName
    synapseSqlPoolSku: synapseSQLPoolSKU
    synapseWorkspaceName: synapseWorkspaceName
  }
}

// Deploy SQL DB
module m_sqlDb 'modules/sql-db.bicep' = if (deployIntegrationMetadataDatabase == true) {
  name: 'SqlDbDeploy'
  params: {
    deploymentMode: deploymentMode
    resourceLocation: SQLLocation
    sqlServerName: SQLServerName
    sqlServerAdminUserName: SQLServerAdminUserName
    sqlServerAdminPassword: r_keyVault.getSecret(SQLServerAdminPassword)
    sqlDbName: SQLDatabaseName
    sqlDbSku: SQLDatabaseSKU
    sqlDbAutoPauseDelay: SQLDatabaseAutoPauseDelay
    sqlDbMinCapacity: SQLDatabaseMinCapacity
  }
}

//********************************************************
// RBAC Role Assignments
//********************************************************

// Assign Storage Blob Reader Role to Purview MSI in the Resource Group as per https://docs.microsoft.com/en-us/azure/purview/register-scan-synapse-workspace
resource r_purviewRgStorageBlobDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (deployPurview == true) {
  name: guid(resourceGroup().name, purviewAccountName, 'Storage Blob Reader')
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRbacStorageBlobDataReaderRoleId)
    principalId: deployPurview ? r_purviewAccount.identity.principalId : ''
    principalType: 'ServicePrincipal'
  }
}

// TODO: Assign Purview Data Curator Role to Synapse MSI in Purview

//********************************************************
// Outputs
//********************************************************
