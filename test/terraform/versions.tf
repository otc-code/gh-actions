terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.59.0"
    }
  }
  backend "local" {}
}
