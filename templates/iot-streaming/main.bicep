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

//Azure EventHub Namespace Parameters
@description('Azure EventHub Namespace Name')
param eventHubNamespaceName string = 'evhns${workloadIdentifier}${resourceInstance}'

@description('Azure EventHub SKU')
param eventHubSKU string = 'Standard'

//----------------------------------------------------------------------

//Stream Analytics Job Parameters
@description('Azure Stream Analytics Job Name')
param streamAnalyticsJobName string = 'asa${workloadIdentifier}${resourceInstance}'

@description('Azure Stream Analytics Job Name')
param streamAnalyticsJobSKU string = 'Standard'

//----------------------------------------------------------------------

//Data Lake Parameters
@description('Data Lake Storage Account Name')
param dataLakeAccountName string = 'st${workloadIdentifier}${resourceInstance}'

@description('Data Lake Resource Group')
param dataLakeAccountResourceGroupName string = '${resourceGroup().name}'

//********************************************************
// Resources
//********************************************************

// Data Lake
resource r_dataLakeStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: dataLakeAccountName
  scope: resourceGroup(dataLakeAccountResourceGroupName)
}

resource r_eventHubNamespace 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: eventHubNamespaceName
  location: resourceLocation
  sku: {
    name: eventHubSKU
    tier: eventHubSKU
    capacity: 1
  }
}

resource r_streamAnalyticsJob 'Microsoft.StreamAnalytics/streamingjobs@2017-04-01-preview' = {
  name: streamAnalyticsJobName
  location: resourceLocation
  properties: {
    sku: {
      name: streamAnalyticsJobSKU
    }
  }
}

//********************************************************
// Outputs
//********************************************************
