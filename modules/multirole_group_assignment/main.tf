#To grab the first 4 of the tenant id
locals {
  prefix = substr(var.tenant_id, 0, 4) # first 6 characters
}

/*
locals {
  prefix = substr(var.tenant_id, 0, 4) # first 6 characters
}
*/

#The role groups that will be assigned multiple roles
resource "azuread_group" "multirole_group" {
  display_name     = "CL-M-USGV-PIM-O-HT-${var.group_name}"
  description      = "Group with multiple roles assigned as eligible permanent"
  security_enabled = true
}

data "azurerm_role_definition" "roles" {
  for_each = toset(var.role_names)
  name     = each.key
  #scope    = "/subscriptions/${var.subscription_id}"
  scope    = "/providers/Microsoft.Management/managementGroups/${var.tenant_id}"
}

resource "time_static" "start" {}

#Assign the roles to the group as a permanent eligible assignment
resource "azurerm_pim_eligible_role_assignment" "multirole_assignments" {
  for_each           = data.azurerm_role_definition.roles
  #scope              = "/subscriptions/${var.subscription_id}"
  scope              = "/providers/Microsoft.Management/managementGroups/${var.tenant_id}"
  role_definition_id = each.value.id
  principal_id       = azuread_group.multirole_group.object_id
  schedule {
    start_date_time = time_static.start.rfc3339
    expiration {} # Permanent assignment
  }
  justification = "Permanent eligible assignment for group"
}