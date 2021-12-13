//********************************************************
// General Parameters
//********************************************************

@description('Workload Identifier')
param workloadIdentifier string = substring(uniqueString(resourceGroup().id), 0, 6)

@description('Resource Instance')
param resourceInstance string = '001'

@description('Resource Location')
param resourceLocation string = resourceGroup().location

//********************************************************
// Resource Config Parameters
//********************************************************

//Azure Data Share Name
@description('Azure Data Share Name')
param dataShareAccountName string = 'ds${workloadIdentifier}${resourceInstance}'

//********************************************************
// Resources
//********************************************************

//Data Share Account
resource r_dataShareAccount 'Microsoft.DataShare/accounts@2020-09-01' = {
  name: dataShareAccountName
  location: resourceLocation
  identity: {
    type: 'SystemAssigned'
  }
}

//********************************************************
// Outputs
//********************************************************
