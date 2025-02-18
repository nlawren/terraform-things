terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6"
}

provider "aws" {
  region                   = "ap-southeast-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "vscode"
}