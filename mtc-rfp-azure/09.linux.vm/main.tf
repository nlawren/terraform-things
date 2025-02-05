# Links:
# Azurerm docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Azurerm vnet docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
# Azurerm subnet docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
# Azurerm network security group: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
# Azurerm network security rule: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
# Azurerm nsg association: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
# Azurerm public ip: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
# Azurerm nic: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
# Azurerm bastion: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host
# Azurerm linux vm: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine

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
  name     = "rfp-resourceg"
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

resource "azurerm_network_security_group" "rfp-nsg" {
  name                = "rfp-nsg"
  location            = azurerm_resource_group.rfp-rg.location
  resource_group_name = azurerm_resource_group.rfp-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "rfp-dev-rule" {
  name                        = "rfp-dev-rule-1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rfp-rg.name
  network_security_group_name = azurerm_network_security_group.rfp-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "rfp-nsga" {
  subnet_id                 = azurerm_subnet.rfp-subnet.id
  network_security_group_id = azurerm_network_security_group.rfp-nsg.id
}

resource "azurerm_public_ip" "rfp-publicip-1" {
  name                = "rfp-publicip-1"
  resource_group_name = azurerm_resource_group.rfp-rg.name
  location            = azurerm_resource_group.rfp-rg.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "rfp-nic" {
  name                = "rfp-nic"
  location            = azurerm_resource_group.rfp-rg.location
  resource_group_name = azurerm_resource_group.rfp-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rfp-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rfp-publicip-1.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "rfp-linux-vm" {
  name                  = "rfp-linux-vm"
  resource_group_name   = azurerm_resource_group.rfp-rg.name
  location              = azurerm_resource_group.rfp-rg.location
  size                  = "Standard_B1s"
  admin_username        = "serveradmin"
  network_interface_ids = [azurerm_network_interface.rfp-nic.id]

  admin_ssh_key {
    username   = "serveradmin"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}