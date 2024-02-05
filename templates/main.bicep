param keyvaultName string
param kvpepName string
param location string
param pesubnet string
param kvdnszone string

param agwname string
param agwtags object
param tier string
param sku string
param availabilityZones int
param autoScaleMinCapacity int
param autoScaleMaxCapacity int
param publicIpAddressName string
param subnetResourceId string

param sslCertificates array
param trustedRootCertificates array
param httpListeners array
param backendAddressPools array
param backendHttpSettings array
param requestRoutingRules array
param frontEndPorts array
param probes array

module keyvault '../modules/key-vault/vaults/main.bicep' = {
  name: keyvaultName
  params: {
    location: location
    name: keyvaultName
  }
}

module keyvaultpep '../modules/network/private-endpoints/main.bicep' = {
  dependsOn: [
    keyvault
  ]
  name: kvpepName
  params: {
    location: location
    subnetId: pesubnet
    targetResourceId: keyvault.outputs.resourceId
    targetResourceName: keyvaultName
    targetSubResourceType: 'Vault'
    privateDnsZoneId: kvdnszone
  }
}

module appgw '../modules/network/application-gateway/main.bicep' = {
  name: agwname
  params: {
    name: agwname
    tags: agwtags
    location: location
    tier: tier
    sku: sku
    availabilityZones: availabilityZones
    autoScaleMinCapacity: autoScaleMinCapacity
    autoScaleMaxCapacity: autoScaleMaxCapacity
    frontEndPorts: frontEndPorts
    httpListeners: httpListeners
    backendAddressPools: backendAddressPools
    backendHttpSettings: backendHttpSettings
    requestRoutingRules: requestRoutingRules
    publicIpAddressName: publicIpAddressName
    subnetResourceId: subnetResourceId
    probes: probes
    sslCertificates: sslCertificates
    trustedRootCertificates: trustedRootCertificates
  }

}
