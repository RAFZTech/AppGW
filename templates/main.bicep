param keyvaultName string
param location string
param pesubnet string
param kvpepName string
param kvdnszone string

module keyvault '../modules/key-vault/vaults/main.bicep' = {
  name: keyvaultName
  params: {
    location: location
    name: keyvaultName
  }
}

module keyvaultpep '../modules/network/private-endpoint/main.bicep' = {
  dependsOn: [
    keyvault
  ]
  name: kvpepName
  params: {
    targetSubResourceType: 'Vault'
    location: location
    subnetId: pesubnet
    targetResourceId: keyvault.outputs.name
    privateDnsZoneId: kvdnszone
    targetResourceName: keyvault.outputs.name
  }

}
