param keyVaultName string
param principalIds array
param principalType string = 'ServicePrincipal'
param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Key Vault Secrets User

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for principalId in principalIds: {
    name: guid(keyVault.id, principalId, roleDefinitionId)
    scope: keyVault
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
      principalId: principalId
      principalType: principalType
    }
  }
]
