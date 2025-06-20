# Module References:
# Service plan: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
# Linux web app: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_id" "random" {
  byte_length = 3
}

resource "azurerm_service_plan" "asp" {
  name                = "isileth-app-plan-${random_id.random.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "isileth-webapp-${random_id.random.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

