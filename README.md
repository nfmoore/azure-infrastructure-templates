# Azure Infrastructure Templates

## Azure Machine Learning AI Platform

To test this deployment create a new resource group and then run a group deployment on `main.bicep`:

```shell
az group create -n ai-platform-azureml-poc-001-rg -l eastus2

az deployment group create \
    --name ai-platform-azureml-deployment \
    --mode Incremental \
    --resource-group ai-platform-azureml-poc-001-rg \
    --template-file  main.bicep \
    --parameters keyVaultName=<key-vault-name> keyVaultResourceGroupName=<key-vault-rg>  synapseWorkspaceName=<synapse-workspace-name>  synapseWorkspaceResourceGroupName=<synapse-workspace-rg> dataLakeAccountName=<data-lake-name> dataLakeAccountResourceGroupName=<data-lake-rg>

```

## Synapse Data Platform

To test this deployment create a new resource group and then run a group deployment on `main.bicep`:

```shell
az group create -n data-platform-synapse-poc-001-rg -l eastus2

az deployment group create \
    --name synapse-data-platform-deployment \
    --mode Incremental \
    --resource-group data-platform-synapse-poc-001-rg \
    --template-file  main.bicep \
    --parameters purviewAccountName=<purview-name> purviewResourceGroupName=<purview-rg> keyVaultName=<key-vault-name> keyVaultResourceGroupName=<key-vault-rg> synapseSqlAdminPassword=<synapse-sql-password>  sqlServerAdminPassword=<sql-server-password> 

```

## Data Governance

To test this deployment create a new resource group and then run a group deployment on `main.bicep`:

```shell
az group create -n data-governance-poc-001-rg -l eastus2

az deployment group create \
    --name data-governance-deployment \
    --mode Incremental \
    --resource-group data-governance-poc-001-rg \
    --template-file data-governance/main.bicep
```
