# Links:
# Azurerm docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Azurerm vnet docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
# Azurerm subnet docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "core"
  features {}
}

resource "azurerm_resource_group" "rfp-rg" {
  name     = "rfp-resources"
  location = "Australia East"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "rfp-vnet" {
  name                = "rfp-network"
  resource_group_name = azurerm_resource_group.rfp-rg.name
  location            = azurerm_resource_group.rfp-rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "rfp-subnet" {
  name                 = "rfp-subnet-1"
  resource_group_name  = azurerm_resource_group.rfp-rg.name
  virtual_network_name = azurerm_virtual_network.rfp-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}