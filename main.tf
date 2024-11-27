provider "azurerm" {
  features {}
  use_oidc = true
}

resource "azurerm_resource_group" "oidc" {
  name     = var.resource_group_name
  location = var.location
}


resource "azuread_access_package_catalog" "catalog1" {
  display_name = "AzureADRoles_PIM"
  description  = "This catalog holds Azure AD roles to be put in access packages"
}
