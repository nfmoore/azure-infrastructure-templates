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
param eventHubNamespaceName string = 'default'

@description('Azure EventHub Name')
param eventHubName string = 'evh${workloadIdentifier}${resourceInstance}'

@description('Azure EventHub SKU')
param eventHubSKU string = 'Standard'

@description('Azure EventHub Partition Count')
param eventHubPartitionCount int = 1
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

  resource r_eventHub 'eventhubs' = {
    name: eventHubName
    properties: {
      messageRetentionInDays: 7
      partitionCount: eventHubPartitionCount
      captureDescription: {
        enabled: true
        skipEmptyArchives: true
        encoding: 'Avro'
        intervalInSeconds: 300
        sizeLimitInBytes: 314572800
        destination: {
          name: 'EventHubArchive.AzureBlockBlob'
          properties: {
            storageAccountResourceId: r_dataLakeStorageAccount.id
            blobContainer: 'raw'
            archiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
          }
        }
      }
    }
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
