variable "location" {
  type    = string
  default = "australiaeast"
}

variable "naming_prefix" {
  type    = string
  default = "isileth"
}

variable "github_repository" {
  type    = string
  default = "gha-terraform-az-template"
}

variable "tag_usage" {
  type    = string
  default = "terraform-state"
}

variable "tag_owner" {
  type    = string
  default = "nlawren"
}
