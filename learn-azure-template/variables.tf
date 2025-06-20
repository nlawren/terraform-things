variable "location" {
  type    = string
  default = "australiaeast"
}

variable "naming_prefix" {
  type    = string
  default = "isileth"
}

variable "tag_usage" {
  type    = string
  default = "terraform-state"
}

variable "tag_owner" {
  type    = string
  default = "nlawren"
}

# Or use this type of configuration below.

variable "resource_group_location" {
  type        = string
  default     = "australiaeast"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}
