param deploymentMode string
param keyVaultLocation string

param keyVaultName string
param purviewIdentityPrincipalId string

resource r_keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: keyVaultLocation
  properties: {
    tenantId: subscription().tenantId
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
        objectId: purviewIdentityPrincipalId
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
