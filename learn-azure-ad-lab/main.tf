terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      # Avoid accidental deletion of VMs without explicit intent
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
  }
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "lab" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "lab" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = [var.vnet_address_space]

  # Point DNS at the DC so domain-joined machines resolve AD correctly.
  # This is updated after DC provisioning — see locals.tf for the reference.
  dns_servers = [local.dc_private_ip]

  tags = var.tags
}

# Workload subnet — DC and workstation live here
resource "azurerm_subnet" "workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.workload_subnet_prefix]
}

# Azure Bastion requires a subnet named exactly "AzureBastionSubnet"
# Minimum /26 for Standard SKU, but /27 is sufficient for Developer SKU
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

# ---------------------------------------------------------------------------
# Network Security Group — Workload subnet
# ---------------------------------------------------------------------------

resource "azurerm_network_security_group" "workload" {
  name                = "${var.prefix}-workload-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  # Allow all intra-subnet traffic (AD replication, RPC, etc.)
  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow Bastion to reach VMs (RDP 3389)
  security_rule {
    name                       = "AllowBastionInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.bastion_subnet_prefix
    destination_address_prefix = "*"
  }

  # Deny all other inbound — no public exposure
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# ---------------------------------------------------------------------------
# Azure Bastion — Developer SKU
# ---------------------------------------------------------------------------

# Remove this - not required for the developer bastion sku
resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix}-bastion-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "lab" {
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Developer"

  # Developer SKU: virtual_network_id instead of ip_configuration block
  virtual_network_id = azurerm_virtual_network.lab.id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Domain Controller VM
# ---------------------------------------------------------------------------

resource "azurerm_network_interface" "dc" {
  name                = "${var.prefix}-dc-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.dc_private_ip
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                = "${var.prefix}-dc"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  # Standard_B2s: 2 vCPU / 4 GB RAM — minimum comfortable size for a DC
  size = "Standard_B2s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [azurerm_network_interface.dc.id]

  os_disk {
    name                 = "${var.prefix}-dc-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  # Needed for the CustomScriptExtension below
  provision_vm_agent = true

  tags = var.tags
}

# Promote the DC: install AD DS and create the forest
resource "azurerm_virtual_machine_extension" "dc_promote" {
  name                 = "promote-dc"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  # The script installs the AD DS role, promotes the VM to a domain controller,
  # and reboots. The VM will be unavailable for ~5 minutes post-apply.
  settings = jsonencode({
    commandToExecute = <<-EOT
      powershell.exe -ExecutionPolicy Unrestricted -Command "
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools;
        Import-Module ADDSDeployment;
        Install-ADDSForest `
          -DomainName '${var.domain_name}' `
          -DomainNetbiosName '${var.domain_netbios_name}' `
          -SafeModeAdministratorPassword (ConvertTo-SecureString '${var.dsrm_password}' -AsPlainText -Force) `
          -InstallDns `
          -Force `
          -NoRebootOnCompletion:$false
      "
    EOT
  })

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Windows Server Domain member VM
# ---------------------------------------------------------------------------

resource "azurerm_network_interface" "ws" {
  name                = "${var.prefix}-ws-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "server" {
  name                = "${var.prefix}-srv"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  # Standard_B2s: 2 vCPU / 4 GB RAM — minimum comfortable size for a member server.
  size = "Standard_B2s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  # Azure Hybrid Benefit: bring your own Windows Server licence, paying only the
  # base compute rate rather than the bundled Microsoft licence surcharge.
  # Requires an eligible Windows Server SA or subscription licence.
  license_type = "Windows_Server"

  network_interface_ids = [azurerm_network_interface.srv.id]

  os_disk {
    name                 = "${var.prefix}-ws-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  provision_vm_agent = true

  # The workstation must wait until the DC promotion is complete and the domain
  # is available before attempting to join.
  depends_on = [azurerm_virtual_machine_extension.dc_promote]

  tags = var.tags
}

# Join the server to the domain
resource "azurerm_virtual_machine_extension" "ws_domain_join" {
  name                 = "domain-join"
  virtual_machine_id   = azurerm_windows_virtual_machine.server.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = ""
    User    = "${var.domain_name}\\${var.admin_username}"
    Restart = "true"
    Options = "3" # 3 = JoinDomain + CreateComputerAccount
  })

  protected_settings = jsonencode({
    Password = var.admin_password
  })

  tags = var.tags
}
