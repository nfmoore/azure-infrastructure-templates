param keyVaultName string

param secretName string
@secure()
param secretValue string

resource r_keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}
