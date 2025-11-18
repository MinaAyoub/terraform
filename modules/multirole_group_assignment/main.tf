resource "azuread_group" "multirole_group" {
  display_name     = var.group_name
  description      = "Group with multiple roles assigned as eligible permanent"
  security_enabled = true
  assignable_to_role = true
}

data "azurerm_role_definition" "roles" {
  for_each = toset(var.role_names)
  name     = each.key
  scope    = "/subscriptions/${var.subscription_id}"
}

resource "time_static" "start" {}

resource "azurerm_pim_eligible_role_assignment" "multirole_assignments" {
  for_each           = data.azurerm_role_definition.roles
  scope              = "/subscriptions/${var.subscription_id}"
  role_definition_id = each.value.id
  principal_id       = azuread_group.multirole_group.object_id
  schedule {
    start_date_time = time_static.start.rfc3339
    expiration {} # Permanent assignment
  }
  justification = "Permanent eligible assignment for group"
}