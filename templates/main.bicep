﻿param keyvaultName string
param kvpepName string
param location string
param pesubnet string
param kvdnszone string

param agwname string
param agwtags object
param tier string
param sku string
param Zones array
param autoScaleMinCapacity int
param autoScaleMaxCapacity int
//param publicIpAddressName string
param frontendIPConfigurations array
param subnetResourceId string

//param sslCertificates array
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

resource appgWUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: '${agwname}-id'
  location: location
}

module appgw '../modules/network/application-gateway/main.bicep' = {
  name: agwname
  params: {
    name: agwname
    tags: agwtags
    location: location
    identity: appgWUser.id
    tier: tier
    sku: sku
    availabilityZones: Zones
    autoScaleMinCapacity: autoScaleMinCapacity
    autoScaleMaxCapacity: autoScaleMaxCapacity
    frontendIPConfigurations: frontendIPConfigurations
    frontEndPorts: frontEndPorts
    httpListeners: httpListeners
    backendAddressPools: backendAddressPools
    backendHttpSettings: backendHttpSettings
    requestRoutingRules: requestRoutingRules
    //publicIpAddressName: publicIpAddressName
    subnetResourceId: subnetResourceId
    probes: probes
    sslCertificates: [
      {
        name: 'Shared-App-Gateway-Certificate'
        properties: {
          keyVaultSecretId: '${keyvault.outputs.uri}/secrets/Shared-App-Gateway-Certificate/'
          // 'https://pft01-edc-dib-cloud-kv01.vault.azure.net:443/secrets/App-Gateway-APIM-SSL-Decryption-Certificate/'
        }
      }
    ]
    //sslCertificates: sslCertificates
    //sslCertificates: []
    // sslCertificates: [{
    //     name: 'Name of the SSL certificate that is unique within an application gateway.'
    //     keyVaultResourceId: keyvault.outputs.resourceId
    //     secretName: 'Key vault secret name.'
    //   }]

    // trustedRootCertificates: trustedRootCertificates
    trustedRootCertificates: []
  }

}
