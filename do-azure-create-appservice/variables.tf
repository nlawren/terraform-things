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

variable "service_plan_prefix" {
  type = string
  default = "asp"
  description = "Prefix of the application service plan"
}
