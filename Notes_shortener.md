### Functional requirements:

Drive us to User Stories.
- URL creation and shortening: allow authors to create short URLs by inputting a full URL.
- Link management: Enable authors to view their short URLS.
- Unique URL generation: ensure each short URL generated is unique to avoid conflicts.
- User authentication: retrict access to our teams.
- Redirection: redirect short url to long URLs.

### Non-functional requirements:

- Scalability: support growing demand, initially handling thousands of links and scaling to support significantly more as clients join.
- Reliability and uptime: minimize downtime, implement robust error handling.
- Performance.
- Cost efficiency.
- User friendly interface.
- Maintainability: codebase and infrastructure should evolve easily with updates and future enhacements.

## System design

- How many urls generated per second?
- Read / write ratio?
- To determine the short url lenght is going to be 62^7 (a-z, A-Z, 0-9) this will give us 3.5 trillion possible urls which is fine because we want to be able to generate 1000 urls per second.

Github. GIT for repository and Github pipelines for the CI/CD
Github actions.

- Github environments in the settings tab (Dev, testing/staging, prod).
-  Create new env -> Environment secrets -> Env variables. The difference between a secret and a variable is the accessibility. 
```
dotnet new list
dotnet new webapi
dotnet new solution
dotnet new sln --name UrlShortener
dotnet sln add Api/Api.csproj --solution-folder Api
```

Create a Github action (CI)
 * Create a workflow.
 * Steps 
 * Create a new action and search for the .NET template. Select that one.
 * The actions will be stored in .github/workflows folder.
 * Job main task (has several steps)
  - Jobs can run in parallel or in sequence. 

API.yml
```yml

# This workflow will build a .NET project
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-net

name: API

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 8.0.x
    - name: Restore dependencies
      run: dotnet restore
    - name: Build
      run: dotnet build --no-restore
    - name: Test
      run: dotnet test --no-build --verbosity normal

```

After we commit our changes the action runs and you can check the steps in Github -> Actions tab.
Continuos Integration pipelines.
Infrastructure as Code in the context of Azure (Bicep) 
- Setting infrastructure and replicate it in different environments. 
- When we change a change in our infrastructure (Dev, staging, prod) we want to apply our changes into all of them so they are all equal.
- It is a recipe (ingredientes, process to execute the recipe (steps)).
- A blueprint of a desired state. 
- Azure -> ARM (Azure resource manager (json) cannot be expressed as programming language) -> Bicep (more dynamic way of wxpress it).
- BICEP -> Converts to ARM -> AZURE.
- Bicep Polumi to write Bicep using C#, JS, Java and Python.

1. Bicep is a domain-specific language (DSL) created by Microsoft specifically for Azure. It provides a more concise and readable syntax for authoring Azure Resource Manager (ARM) templates and is tightly integrated with Azure.

2. Terraform is a cloud-agnostic IaC tool that supports multiple cloud providers (Azure, AWS, Google Cloud, etc.) through a plugin system called "providers." With Terraform, you can manage resources across different clouds and services using a single language (HashiCorp Configuration Language, HCL).


Create infrastructure folder
- Create main.bicep (entry point for infrastructure as code. Deploy code of our web application).
- In Azure you can put all your services related inside of a resource. 
main.bicep (basic)
```bicep
param name string = 'api'
var fullName = 'web.${name}'
param location string = resourceGroup().location
resource api 'Microsoft.Web/sites@2024-04-01' = {
  name: fullName
  location: location
  properties: {
    displayName: fullName
  }
}
```

- Create modules folders to reuse a resource (call) from different bicep files (webapp)
- 

Certainly! Here’s a breakdown of what your appservice.bicep file does:

```bicep
param location string = resourceGroup().location
param appsServicePlanName string 
param appName string
```
- **Parameters**:  
  - `location`: Where resources will be deployed (defaults to the resource group’s location).
  - `appsServicePlanName`: Name for the App Service Plan.
  - `appName`: Name for the Web App.

---

```bicep
resource appsServicePlan 'Microsoft.web/serverfarms@2023-12-01' = {
  kind: 'linux'
  location: location
  name: appsServicePlanName
  properties: {
    reserved: true  
  }
  sku: {
    name: '01'
  }
}
```
- **App Service Plan**:  
  - Creates a Linux-based App Service Plan (the compute resource for hosting web apps).
  - `sku.name: '01'` likely refers to a basic pricing tier.

---

```bicep
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appsServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
  }
}
```
- **Web App**:  
  - Creates a Web App using the App Service Plan above.
  - Enforces HTTPS only.
  - Configures the app to run on .NET 8.0 (Linux).

---

```bicep
resource webAppConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'web'
  properties: {
   scmType: 'GitHub'
  }
}
```
- **Web App Configuration**:  
  - Sets the deployment source (`scmType`) to GitHub for the Web App.

---

```bicep
output appServiceId string = webApp.id
```
- **Output**:  
  - Exposes the resource ID of the created Web App.

---

**Summary:**  
App Service Plan
This Bicep module provisions an Azure App Service Plan (Linux), a .NET 8 Web App, configures it for GitHub deployment, and outputs the Web App’s resource ID.

Web App
Creates a Web App using the App Service Plan above.
Enforces HTTPS only.
Configures the app to run on .NET 8.0 (Linux).

Web App Configuration:
Sets the deployment source (scmType) to GitHub for the Web App.

appservice.bicep
```bicep
param location string = resourceGroup().location
param appsServicePlanName string 
param appName string

resource appsServicePlan 'Microsoft.web/serverfarms@2023-12-01' = {
  kind: 'linux'
  location: location
  name: appsServicePlanName
  properties: {
    reserved: true  
  }
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appsServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
  }
}

resource webAppConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'web'
  properties: {
   scmType: 'GitHub'
  }
}

output appServiceId string = webApp.id


```
- Modify main.bicep to call the module
```bicep
param location string = resourceGroup().location
var uniqueId = uniqueString(resourceGroup().id)

module apiService 'modules/compute/appservice.bicep' = {
  name: 'apiDeployment'
  params: {
    location: location
    appsServicePlanName: 'plan-api-${uniqueId}' 
    appName: 'api-${uniqueId}'
  }
}
```

- Create a resource group in Azure using Azure CLI
```bash
 az group create --name urlshortener-dev --location southcentralus
```
- Command to delete
```bash
az group delete --name <your-resource-group-name>
```
- Run bicep scripts to deploy inside of the resource 
- You can use the what-if option to check what would happen if you execute the command
```bash
az deployment group what-if --resource-group urlshortener-dev --template-file infrastructure/main.bicep
```
- To actually execute the command change what-if for create.

```bash
az deployment group create --resource-group urlshortener-dev --template-file infrastructure/main.bicep
```

- Github actions to automate deployment:
- Create new Yml file for the Development environment:

- Workflow Name
Azure Deploy: The name shown in the GitHub Actions UI.
Triggers

on:
push: Runs when you push to the main branch and files under infrastructure/** change.

pull_request: Runs when a pull request changes files under infrastructure/**.

workflow_dispatch: Allows you to manually trigger the workflow from the GitHub UI.

## Jobs
deploy-dev: The only job in this workflow.
runs-on: ubuntu-latest: Uses the latest Ubuntu runner.
environment: Development: Associates this job with the "Development" environment in GitHub.

## Steps
Checkout code

- Uses the actions/checkout@v4 action to clone your repository into the runner.

## Azure login

Uses the azure/login@v2.1.1 action to authenticate to Azure using credentials stored in GitHub Secrets (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID).

## Create Resource Group

- Uses the azure/CLI@v2 action to run an inline Bash script.
The script creates an Azure resource group using the name and location from workflow variables (${{vars.RESOURCE_GROUP_NAME}}, ${{vars.RESOURCE_GROUP_LOCATION}}).
Deploy Bicep Template

- Uses the azure/arm-deploy@v2 action to deploy your Bicep template (main.bicep) to the specified resource group.
scope: resourcegroup tells the action to deploy at the resource group level.
resourceGroupName and template specify the target group and the Bicep file.

## Summary
This workflow:

Runs on pushes, PRs, or manually.
Logs into Azure.
Ensures the resource group exists.
Deploys your infrastructure using a Bicep template.

```yml
name: 'Azure Deploy'

on:
 push:
  branches: 
   - main
  paths:
    - infrastructure/**
 pull_request:
  paths:
  - infrastructure/**
 workflow_dispatch: # manual trigger

permissions:
  id-token: write
  contents: read


jobs:
 deploy-dev:
    runs-on: ubuntu-latest
    environment: Development
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Azure login
        uses: azure/login@v2.1.1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - uses: azure/CLI@v2
        with:
          inlineScript: |
           #!/bin/bash
           az group create --name ${{vars.RESOURCE_GROUP_NAME}} --location ${{vars.RESOURCE_GROUP_LOCATION}}
           echo "Azure resource group created successfully."
      - name: Deploy
        uses: azure/arm-deploy@v2
        with:
          scope: resourcegroup
          resourceGroupName: ${{vars.RESOURCE_GROUP_NAME}}
          template: ./infrastructure/main.bicep


```

- Go to github -> Settings -> Environments - Dev and configure the secrets there.
Resource group name is a variable
- You can go to Secrets and variables to create global Environment variables and secrets instead of creating them for each environment.
- Create the subscription id in the repository variable (it's not a secret).
- Create user for GH actions in Azure 

```
az ad sp create-for-rbac --name "GitHub-Actions-SP" \
  --role contributor \
  --scopes /subscriptions/5e6e7428-43f2-4575-a785-c6af3b719d50 \
  --sdk-auth

  {
  "clientId": "",
  "clientSecret": "",
  "subscriptionId": ",
  "tenantId": "",
  "activeDirectoryEndpointUrl": "",
  "resourceManagerEndpointUrl": "",
  "activeDirectoryGraphResourceId": "",
  "sqlManagementEndpointUrl": "",
  "galleryEndpointUrl": "",
  "managementEndpointUrl": ""
}
```

- We get the clientid and the tenant-id from there

# Configure a federated identity credential on an app


in Azure portal

Go to Try Microsoft Entra admin center
Secure your identity environment with Microsoft Entra ID, permissions management and more.
Go to Microsoft Entra-> All Applications -> App registrations -> Find Github-Actions-SP -> Certificates and secrets -> Federated credentials -> Github Actions deploying Azure resources

- Push the changes to main and it should deploy your changes to azure

- Create a sequence to apply to Dev -> Staging -> Prd
- Deploy to production manually or if the codes into the main branch and if the previous env deployment were succesfully. 
- Add a new job for each environment in the azure-deploy.yml

- Configure the environment variables for each env in GitHub environments (settings).
- In Azure create federated credentials for Staging and Production environments.
- Push your changes.
- Modify api.yml to publish your code to the resource group.
- Command to get the AZURE_WEBAPP_PUBLISH_PROFILE:
```
az webapp deployment list-publishing-profiles --name api-tv2efnbtk6qio --resource-group urlshortener-dev --xml
```
- Paste that xml result to the secrets in Development environment.
- After you publish you can consume the api:

https://api-tv2efnbtk6qio.azurewebsites.net/weatherforecast

Settings of application access to those settings.
DIfferent ways to store and retrieve pieces of configuration:
Configurations -> App settings
               -> env variables
               -> secret managers

- Azure Key vault 
- Create a new module inside infrastructure/modules for secrets and create the keyvault.bicep file 