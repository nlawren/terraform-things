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
  features {}
}

resource "azurerm_resource_group" "rfp-rg" {
  name = "rfp-resources"
  location = "Australia East"
  tags = {
    environment = "dev"
  }
}
