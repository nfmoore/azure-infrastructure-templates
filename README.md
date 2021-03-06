# Azure Infrastructure Templates

## Overview

This repository aims to accelerate the deployment of common workloads in Azure. It has been implemented through the use of Azure Bicep declarative infrastructure as code. It has been designed around five types of workloads - data management and analytics, machine learning and artifical intellegence, the internet of things (IoT), application development and cloud infrastructure.

## Template Details

Each template aims to deploy infrastructure to address common cloud workloads. These templates have simple configurations which are suitable for proof-of-concepts. These templates will not meet enteprise security requirements.

| Template   | Description | Deploy to Azure |
|:---------------------------|:------------|:----------------|
| Data Management | Solution with services to manage and govern data assets across your organisation, monitor the logs and metrics of data services, securely store keys and secrets, and share data with third parties. | &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fmain%2Ftemplates%2Fdata-management%2Fmain.json) &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; |
| Synapse Workspace | Solution for an enterprise analytics service that accelerates time to insight across data warehouses and big data systems. | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fmain%2Ftemplates%2Fdata-synapse-workspace%2Fmain.json) |
| Databricks Workspace | Solution for a unified platform for data, analytics and artificial intelligence.| [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fmain%2Ftemplates%2Fdata-databricks-workspace%2Fmain.json) |
| Machine Learning Workspace | Solution for accelerating and managing the development, deployment and monitoring of machine learning models. | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fmain%2Ftemplates%2Fai-azureml-workspace%2Fmain.json) |
| IoT Streaming | Solution to ingest data streams generated by client applications or IoT devices and process data streams in real-time. | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fmain%2Ftemplates%2Fiot-streaming%2Fmain.json) |
| Application Microservices | Solution to quickly deploy and operate a microservices-based architecture. | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnfmoore%2Fazure-infrastructure-templates%2Fmain%2Ftemplates%2Fapps-microservices%2Fmain.json) |

## License

Details on licensing for the project can be found in the [LICENSE](./LICENSE) file.
