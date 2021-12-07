param logAnalyticsWorkspaceName string
param resourceLocation string

param logAnalyticsWorkspaceSku string
param logAnalyticsWorkspaceDailyQuota int
param logAnalyticsWorkspaceRetentionPeriod int

// Log Analytics Workspace
resource r_logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: resourceLocation
  properties: {
    retentionInDays: logAnalyticsWorkspaceRetentionPeriod
    sku: {
      name: logAnalyticsWorkspaceSku
    }
    workspaceCapping: {
      dailyQuotaGb: logAnalyticsWorkspaceDailyQuota
    }
  }
}

output storageAccountID string = r_logAnalyticsWorkspace.id
output storageAccountName string = r_logAnalyticsWorkspace.name
