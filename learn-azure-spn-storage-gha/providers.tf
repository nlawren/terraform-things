terraform {

  required_version = ">=1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}


##
# Provider configuration
##

provider "azurerm" {
  features {}
}

provider "random" {
  # Configuration options available
}

provider "azuread" {
  # Configuration options
}

provider "github" {
  # Configuration options
}
