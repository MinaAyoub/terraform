terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.52.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.6.0"
    }
    
  }

  backend "azurerm" {
    key              = "terraform.tfstate"
    use_oidc         = true
    use_azuread_auth = true
  }
}