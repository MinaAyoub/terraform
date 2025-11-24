locals {
  prefix = substr(var.subscription_id, 0, 4) # first 6 characters
}

#The owner group who will approve requests and reviews
resource "azuread_group" "role_owners" {
  display_name      = "SGG-US-ALL-PIM-O-HT-AP_USPOTS_APPROVERS"
  description       = "This group is the approver and reviewer for the Az resource roles and their access reviews"
  security_enabled  = true
}

#The requestor admin group, the team who CAN request access to the APs
resource "azuread_group" "admin_group" {
  display_name      = "SGG-US-ALL-PIM-O-HT-AP_USPOTS_REQUESTORS"
  description       = "This group will contain admins who able to request access packages containing az resource roles"
  security_enabled  = true
}

#The role group for individual roles
resource "azuread_group" "groups" {
  for_each          = toset(var.roles_names)
  display_name      = "CL-M-USGV-PIM-O-HT-AP_${each.key}-${local.prefix}"
  description       = "This group is assigned the specific roles specified in name"
  security_enabled  = true
}


#To grab the role definitions for the roles in the variables under the given scope
data "azurerm_role_definition" "roles" {
  for_each = toset(var.roles_names)
  name     = each.key
  #scope    = "/subscriptions/${var.subscription_id}"
  scope    = "/providers/Microsoft.Management/managementGroups/${var.tenant_id}"
}

resource "time_static" "start" {}

#To assign the role to the group on a permanent eligible assignment
resource "azurerm_pim_eligible_role_assignment" "example" {
  for_each            = data.azurerm_role_definition.roles
  #scope               = "/subscriptions/${var.subscription_id}"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.tenant_id}"
  role_definition_id  = each.value.id
  principal_id        = azuread_group.groups[each.key].object_id
  schedule {
    start_date_time = time_static.start.rfc3339
    expiration {}
  }
  justification = "Permanent eligible assignment for admins"
}
