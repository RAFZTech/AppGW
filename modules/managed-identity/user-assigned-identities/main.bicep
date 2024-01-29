@description('User Assigned Managed Identity name')
param name string = ''

@description('User Assigned Managed Identity type, User or ServicePrincipal')
param principalType string = 'ServicePrincipal'

@description('ID of RBAC role definition, see https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for guids')
param roleDefinitionIds array = [
  // 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // reader
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // contributor
  // '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' // owner
]

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Managed Identity resource location')
param location string = resourceGroup().location

@description('Skip RBAC if true and accept default assignment')
param skipRbac bool = false

var rbacAssignments = [for roleDefinitionId in roleDefinitionIds: {
  name: guid(managedIdentity.id, resourceGroup().id, roleDefinitionId)
  roleDefinitionId: roleDefinitionId
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: name
  location: location
  tags: tags
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for rbacAssignment in rbacAssignments: if (skipRbac == false) {
  name: rbacAssignment.name
  scope: resourceGroup()
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacAssignment.roleDefinitionId)
    principalType: principalType
  }
}]

output managedIdentityName string = managedIdentity.name
output managedIdentityResourceId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
