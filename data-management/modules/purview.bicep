param deploymentMode string
param purviewLocation string

param purviewAccountName string
param purviewManagedRgName string

//Purview Account
resource r_purviewAccount 'Microsoft.Purview/accounts@2020-12-01-preview' = {
  name: purviewAccountName
  location: purviewLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: (deploymentMode == 'secure') ? 'Disabled' : 'Enabled'
    managedResourceGroupName: purviewManagedRgName
  }
}

output purviewAccountID string = r_purviewAccount.id
output purviewAccountName string = r_purviewAccount.name
output purviewIdentityPrincipalID string = r_purviewAccount.identity.principalId
output purviewScanEndpoint string = r_purviewAccount.properties.endpoints.scan
output purviewAPIVersion string = r_purviewAccount.apiVersion