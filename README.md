# Azure Infrastructure Templates

## Overview

This repository aims to accelerate the depoyment of common Data and AI workloads in Azure. It has been implemented through the use of Azure Bicep declarative infrastructure as code. It includes templates to deploy for:
 - Data Management: common tools for governance and monitoring of data resources.
 - Synapse Workspace: enterprise analytics service that accelerates time to insight across data warehouses and big data systems.
 - Machine Learning Workspace: enterprise-grade machine learning  service for the end-to-end machine learning lifecycle.

## Data Management

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fdata-management%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n data-management-poc-001-rg -l eastus2

az deployment group create \
    --name data-management-deployment \
    --mode Incremental \
    --resource-group data-management-poc-001-rg \
    --template-file data-management/main.bicep
```

For more information, see the following articles:

- [Azure Purview documentation](https://docs.microsoft.com/en-us/azure/purview/)
- [Azure Key Vault documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure Monitor Logs overview](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/data-platform-logs)

## Synapse Workspace

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fdata-synapse-workspace%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n data-synapse-workspace-poc-001-rg -l eastus2

az deployment group create \
    --name data-synapse-workspace-deployment \
    --mode Incremental \
    --resource-group data-synapse-workspace-poc-001-rg \
    --template-file  data-synapse-workspace/main.bicep \
    --parameters purviewAccountName=<purview-name> purviewResourceGroupName=<purview-rg> keyVaultName=<key-vault-name> keyVaultResourceGroupName=<key-vault-rg> synapseSqlAdminPassword=<synapse-sql-password>  sqlServerAdminPassword=<sql-server-password> 

```

For more information, see the following articles:

- [Azure Synapse Analytics documentation](https://docs.microsoft.com/en-us/azure/synapse-analytics/)

## Machine Learning Workspace

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fai-azureml-workspace%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n ai-azureml-workspace-poc-001-rg -l eastus2

az deployment group create \
    --name ai-azureml-workspace-deployment \
    --mode Incremental \
    --resource-group ai-azureml-workspace-poc-001-rg \
    --template-file  ai-azureml-workspace/main.bicep \
    --parameters keyVaultName=<key-vault-name> keyVaultResourceGroupName=<key-vault-rg>  synapseWorkspaceName=<synapse-workspace-name>  synapseWorkspaceResourceGroupName=<synapse-workspace-rg> dataLakeAccountName=<data-lake-name> dataLakeAccountResourceGroupName=<data-lake-rg>

```

For more information, see the following articles:

- [Azure Machine Learning documentation](https://docs.microsoft.com/en-us/azure/machine-learning/)

## IoT Streaming

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fiot-streaming%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n iot-streaming-poc-001-rg -l eastus2

az deployment group create \
    --name iot-streaming-deployment \
    --mode Incremental \
    --resource-group iot-streaming-poc-001-rg \
    --template-file  iot-streaming/main.bicep \
    --parameters dataLakeAccountName=<data-lake-name> dataLakeAccountResourceGroupName=<data-lake-rg>

```

For more information, see the following articles:

- [Azure Event Hubs documentation](https://docs.microsoft.com/en-au/azure/event-hubs/)
- [Azure Stream Analytics documentation](https://docs.microsoft.com/en-us/azure/stream-analytics/)

## License
Details on licensing for the project can be found in the [LICENSE](./LICENSE) file.
