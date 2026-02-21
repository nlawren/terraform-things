# Module References:
# Service plan: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
# Linux web app: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app
# Random: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
# Note: 20250825 - keeping the linux web app name constant - previously used ${random_id.random.hex}
#       20260218 - added an extra dev webapp following the AZ400 course

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_id" "random" {
  byte_length = 4
}

resource "random_pet" "random" {
  for_each = local.active_environments
  prefix   = var.service_plan_prefix
}

resource "azurerm_service_plan" "asp" {
  for_each = local.active_environments

  name                = "${random_pet.random[each.key].id}-${each.key}-plan-${each.value.sku}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = each.value.sku
}

resource "azurerm_linux_web_app" "webapp" {
  for_each = local.active_environments

  name                = "isileth-webapp-7768ee70-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp[each.key].id
  https_only          = true

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "8.0"
    }
  }
}
