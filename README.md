# Azure Infrastructure Templates

## Overview

This repository aims to accelerate the depoyment of common Data and AI workloads in Azure. It has been implemented through the use of Azure Bicep declarative infrastructure as code. It includes templates to deploy for:

- Data Management: common tools for governance and monitoring of data resources.
- Synapse Workspace: enterprise analytics service that accelerates time to insight across data warehouses and big data systems.
- Machine Learning Workspace: enterprise-grade machine learning  service for the end-to-end machine learning lifecycle.

The services across each template address one or more different problems of data, AI and IoT use-cases - governance and management, ingestion, storage, processing, enrichment, serving. The following diagram illustrates the different services and the problems they address where each template has been outlined with a dashed box.

<img src="./.github/docs/diagrams/infrastructure-templates-overview.png" alt="infrastructure-templates-overview" width="680" />

> Please note the templates in this repository are intended for proof-of-concept deployments. For a more production ready solution see: [Azure Analytics End to End with Azure Synapse - Deployment Accelerator](https://github.com/fabragaMS/AzureAnalyticsE2E)

## Deployment

The different templates of this this repository can be deployed independently or as part of a whole solution. Some services within a template can be conditionally deployed based on deployment parameters to better suit the needs of the workload.

### Data Management

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
- [Overview of Log Analytics in Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)
- [Azure Monitor Logs overview](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/data-platform-logs)

### Synapse Workspace

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
- [Azure Storage documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Azure SQL Database documentation](https://docs.microsoft.com/en-us/azure/azure-sql/database/)

### Machine Learning Workspace

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
- [Azure Storage documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Azure Key Vault documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [What is Application Insights?](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

### Databricks Workspace

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fdata-databricks-workspace%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n data-databricks-workspace-poc-001-rg -l eastus2

az deployment group create \
    --name data-databricks-workspace-deployment \
    --mode Incremental \
    --resource-group data-databricks-workspace-poc-001-rg \
    --template-file  data-databricks-workspace/main.bicep  \
    --parameters databricksManagedResourceGroupName=<managed-resource-group-name> 

```

For more information, see the following articles:
- [Azure Databricks documentation](https://docs.microsoft.com/en-us/azure/databricks/)
- [Azure Storage documentation](https://docs.microsoft.com/en-us/azure/storage/)

### IoT Streaming

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fiot-streaming%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n iot-streaming-poc-001-rg -l eastus2

az deployment group create \
    --name iot-streaming-deployment \
    --mode Incremental \
    --resource-group iot-streaming-poc-001-rg \
    --template-file  iot-streaming/main.bicep

```

For more information, see the following articles:

- [Azure Event Hubs documentation](https://docs.microsoft.com/en-au/azure/event-hubs/)
- [Azure Stream Analytics documentation](https://docs.microsoft.com/en-us/azure/stream-analytics/)

### Data Sharing

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fdevelopment%2Fdata-sharing%2Fmain.json)

To execute this depoyment using CLI create a new resource group and then run a group deployment on `main.bicep`. For example:

```shell
az group create -n data-sharing-poc-001-rg -l eastus2

az deployment group create \
    --name data-sharing-deployment \
    --mode Incremental \
    --resource-group data-sharing-poc-001-rg \
    --template-file  data-sharing/main.bicep
```

For more information, see the following articles:
- [Azure Data Share documentation](https://docs.microsoft.com/en-us/azure/data-share/)

## License
Details on licensing for the project can be found in the [LICENSE](./LICENSE) file.
