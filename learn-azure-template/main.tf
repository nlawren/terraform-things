locals {
  resource_group_name = "${var.naming_prefix}-${random_integer.sa_num.result}"
}

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

resource "azurerm_resource_group" "rg2" {
  name     = "rg2-${random_id.random.id}"
  location = var.resource_group_location
}
