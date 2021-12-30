param resourceLocation string

param sqlServerName string
param sqlServerAdminUserName string
@secure()
param sqlServerAdminPassword string

param sqlDbName string
param sqlDbSku object
param sqlDbAutoPauseDelay int
param sqlDbMinCapacity int

// Azure SQL Server
resource r_sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location: resourceLocation
  properties: {
    administratorLogin: sqlServerAdminUserName
    administratorLoginPassword: sqlServerAdminPassword
  }

  // Default Firewall Rules - Allow All Traffic
  resource r_sqlServerFirewallAllowAll 'firewallRules' = {
    name: 'AllowAllNetworks'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }

  // Firewall Allow Azure Sevices
  // Required for Post-Deployment Scripts
  resource r_sqlServerFirewallAllowAzure 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

// Azure SQL Database
resource r_sqlDb 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: r_sqlServer
  name: sqlDbName
  location: resourceLocation
  sku: sqlDbSku
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    autoPauseDelay: sqlDbAutoPauseDelay
    minCapacity: sqlDbMinCapacity
    requestedBackupStorageRedundancy: 'Local'
  }
}

// TODO: Configure Azure AD authentication 

output sqlServerId string = r_sqlServer.id
output sqlServerName string = r_sqlServer.name
output sqlDbId string = r_sqlDb.id
output sqlDbName string = r_sqlDb.name
