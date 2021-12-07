# Azure Infrastructure Templates

## Azure Machine Learning AI Platform

To test this deployment create a new resource group and then run a group deployment on `main.bicep`:

```shell
az group create -n ai-azureml-workspace-poc-001-rg -l eastus2

az deployment group create \
    --name ai-azureml-workspace-deployment \
    --mode Incremental \
    --resource-group ai-azureml-workspace-poc-001-rg \
    --template-file  ai-azureml-workspace/main.bicep \
    --parameters keyVaultName=<key-vault-name> keyVaultResourceGroupName=<key-vault-rg>  synapseWorkspaceName=<synapse-workspace-name>  synapseWorkspaceResourceGroupName=<synapse-workspace-rg> dataLakeAccountName=<data-lake-name> dataLakeAccountResourceGroupName=<data-lake-rg>

```

## Synapse Data Platform

To test this deployment create a new resource group and then run a group deployment on `main.bicep`:

```shell
az group create -n data-synapse-workspace-poc-001-rg -l eastus2

az deployment group create \
    --name data-synapse-workspace-deployment \
    --mode Incremental \
    --resource-group data-synapse-workspace-poc-001-rg \
    --template-file  data-synapse-workspace/main.bicep \
    --parameters purviewAccountName=<purview-name> purviewResourceGroupName=<purview-rg> keyVaultName=<key-vault-name> keyVaultResourceGroupName=<key-vault-rg> synapseSqlAdminPassword=<synapse-sql-password>  sqlServerAdminPassword=<sql-server-password> 

```

## Data Management

To test this deployment create a new resource group and then run a group deployment on `main.bicep`:

```shell
az group create -n data-management-poc-001-rg -l eastus2

az deployment group create \
    --name data-management-deployment \
    --mode Incremental \
    --resource-group data-management-poc-001-rg \
    --template-file data-management/main.bicep

```
