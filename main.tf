provider "azurerm" {
  features {}
  use_oidc = true
}
provider "azuread" {}

module "roles_and_groups" {
  source          = "./modules/roles_and_groups"
  roles_names     = var.roles_names
  subscription_id = var.subscription_id
}

module "identity_governance" {
  source      = "./modules/identity_governance"
  groups      = module.roles_and_groups.groups
  admin_group = module.roles_and_groups.admin_group
  role_owners = module.roles_and_groups.role_owners
}
