##
# Locals
##
locals {
  resource_group_name    = "${var.naming_prefix}-${random_integer.sa_num.result}"
  storage_account_name   = "${lower(var.naming_prefix)}${random_integer.sa_num.result}"
  service_principal_name = "${var.naming_prefix}-${random_integer.sa_num.result}"
}

## Create Azure Entra Service Principal ##

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}

resource "azuread_application" "gh_actions" {
  display_name = local.service_principal_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "gh_actions" {
  client_id = azuread_application.gh_actions.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "gh_actions" {
  service_principal_id = azuread_service_principal.gh_actions.object_id
}

## This assigns contributor role to the service principal ##

resource "azurerm_role_assignment" "gh_actions" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.gh_actions.id
}

## Create an Azure resource group an an Azure Storage Account to store Terraform State ##

resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}


resource "azurerm_resource_group" "setup" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    usage = var.tag_usage
    owner = var.tag_owner
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    usage = var.tag_usage
    owner = var.tag_owner
  }
}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name

}

## Store the Service Principal ID, Password, plus information about the storage account and Azure subscription in GitHub Secrets ##

resource "github_actions_secret" "actions_secret" {
  for_each = {
    STORAGE_ACCOUNT     = azurerm_storage_account.sa.name
    RESOURCE_GROUP      = azurerm_storage_account.sa.resource_group_name
    CONTAINER_NAME      = azurerm_storage_container.ct.name
    ARM_CLIENT_ID       = azuread_service_principal.gh_actions.client_id
    ARM_CLIENT_SECRET   = azuread_service_principal_password.gh_actions.value
    ARM_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    ARM_TENANT_ID       = data.azuread_client_config.current.tenant_id
  }

  repository      = var.github_repository
  secret_name     = each.key
  plaintext_value = each.value
}
