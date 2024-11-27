provider "azurerm" {
  features {}
  "resource_provider_registrations = "none"
  use_oidc = true
}

resource "azurerm_resource_group" "oidc" {
  name     = var.resource_group_name
  location = var.location
}
