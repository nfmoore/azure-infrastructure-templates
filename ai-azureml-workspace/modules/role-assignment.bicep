param name string
param roleId string
param principalId string

resource r_scopedRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: name
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
