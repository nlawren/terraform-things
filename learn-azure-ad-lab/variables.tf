variable "prefix" {
  description = "Short prefix applied to all resource names."
  type        = string
  default     = "adlab"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "australiaeast"
}

variable "vnet_address_space" {
  description = "CIDR block for the lab VNet."
  type        = string
  default     = "10.10.0.0/16"
}

variable "workload_subnet_prefix" {
  description = "CIDR for the workload subnet (DC + workstation)."
  type        = string
  default     = "10.10.1.0/24"
}

# Confirm - not required
variable "bastion_subnet_prefix" {
  description = "CIDR for AzureBastionSubnet. Must be at least /27 for Developer SKU."
  type        = string
  default     = "10.10.0.0/27"
}

variable "domain_name" {
  description = "Fully qualified domain name for the new AD forest (e.g. corp.local)."
  type        = string
  default     = "corp.local"
}

variable "domain_netbios_name" {
  description = "NetBIOS name for the domain (15 chars max, no dots)."
  type        = string
  default     = "CORP"
}

variable "admin_username" {
  description = "Local administrator username for both VMs (also used as domain admin)."
  type        = string
  default     = "labadmin"
}

variable "admin_password" {
  description = "Password for the local/domain administrator account."
  type        = string
  sensitive   = true
}

variable "dsrm_password" {
  description = "Directory Services Restore Mode (DSRM) password for the DC."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    environment = "lab"
    managed-by  = "terraform"
  }
}
