output "multirole_group" {
  value = azuread_group.multirole_group
}

output "role_assignments" {
  value = azurerm_pim_eligible_role_assignment.multirole_assignments
}