param Vnet string
param appgwSnet string
param peSnet string
param appgwSnetCidr string
param peSnetCidr string
param appgwNsg string
param peNsg string
param appgwRt string
param peRt string
param location string
param appgwRules array
param peRules array
param appgwRoutes array
param peRoutes array

module agwNsg '../modules/network/network-security-group/main.bicep' = {
  name: appgwNsg
  params: {
    name: appgwNsg
    location: location
    securityRules: appgwRules
  }
}

module pepNsg '../modules/network/network-security-group/main.bicep' = {
  name: peNsg
  params: {
    name: peNsg
    location: location
    securityRules: peRules
  }
}

module agwRt '../modules/network/route-tables/main.bicep' = {
  name: appgwRt
  params: {
    name: appgwRt
    location: location
    routes: appgwRoutes
  }
}

module pepRt '../modules/network/route-tables/main.bicep' = {
  name: peRt
  params: {
    name: peRt
    location: location
    routes: peRoutes
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' existing = {
  name: Vnet
}

resource agwsnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  parent: vnet
  name: appgwSnet
  properties: {
    addressPrefix: appgwSnetCidr
    networkSecurityGroup: {
      id: appgwNsg
    }
    routeTable: {
      id: appgwRt
    }
  }
}

resource pepsnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  parent: vnet
  name: peSnet
  properties: {
    addressPrefix: peSnetCidr
    networkSecurityGroup: {
      id: peNsg
    }
    routeTable: {
      id: appgwRt
    }
  }
}
