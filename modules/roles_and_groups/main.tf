resource "azuread_group" "groups" {
  for_each          = toset(var.roles_names)
  display_name      = "RoleGrp_AzResourceRole_${each.key}"
  description       = "This group is assigned the specific roles specified in name"
  security_enabled  = true
}

resource "azuread_group" "role_owners" {
  display_name      = "ApproverGrp_AzResourceRoles"
  description       = "This group is the approver and reviewer for the Az resource roles and their access reviews"
  security_enabled  = true
}

resource "azuread_group" "admin_group" {
  display_name      = "RequstGrp_AzResourceRoles_AccessPackages"
  description       = "This group will contain admins who able to request access packages containing az resource roles"
  security_enabled  = true
}

data "azurerm_role_definition" "roles" {
  for_each = toset(var.roles_names)
  name     = each.key
  scope    = "/subscriptions/${var.subscription_id}"
}

resource "time_static" "start" {}

resource "azurerm_pim_eligible_role_assignment" "example" {
  for_each            = data.azurerm_role_definition.roles
  scope               = "/subscriptions/${var.subscription_id}"
  role_definition_id  = each.value.id
  principal_id        = azuread_group.groups[each.key].object_id
  schedule {
    start_date_time = time_static.start.rfc3339
    expiration {}
  }
  justification = "Permanent eligible assignment for admins"
}
