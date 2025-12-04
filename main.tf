provider "azurerm" {
  features {}
  use_oidc = true
}
provider "azuread" {}

module "roles_and_groups" {
  source          = "./modules/roles_and_groups"
  roles_names     = var.roles_names
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Multi-role group assignment modules (one per group)
module "multirole_group_assignment" {
  for_each        = var.multi_role_groups
  source          = "./modules/multirole_group_assignment"
  group_name      = each.key
  role_names      = each.value
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Merge all groups for identity governance
locals {
  all_groups = merge(
    module.roles_and_groups.groups,
    { for k, v in module.multirole_group_assignment : k => v.multirole_group }
  )
}

module "identity_governance" {
  source      = "./modules/identity_governance"
  groups      = local.all_groups
  admin_group = module.roles_and_groups.admin_group
  role_owners = module.roles_and_groups.role_owners
  mi_client_id    = var.mi_client_id
}

