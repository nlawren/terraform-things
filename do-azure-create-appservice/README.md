# Azure App Service Deployment with a Linux Free Tier Web App

This terraform code is to setup a number of Azure App Service Plans, with a Linux Web app for each ASP. By default these are on the free F1 tier SKU but each SKU can be configured differently if required. These are setup for the .Net8 framework (which is not configurable unless edited and will apply to all webapps).

The main function of this code is to setup the a number of environments and plans service for an Azure DevOps deployment as part of the Cloud Lee AZ400 course.

Useful links:

- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/app-service/provision-resource-terraform?tabs=linux) on how to deploy this via terraform. Also includes a section on deploying direct from Github.
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans) on the various tiers of the Azure App Service.

Provider details are accurate as of February 2026.

By default, the terraform configuration will setup a dev, test, staging and prod environment which can be deactivated by either editing variables.tf or by passing cli options.
