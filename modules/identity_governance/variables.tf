variable "groups" {
  description = "Map of Azure AD groups"
  type        = map(any)
}
variable "admin_group" {
  description = "Admin group object"
  type        = any
}
variable "role_owners" {
  description = "Role owners group object"
  type        = any
}

variable "mi_objid" {
  type        = string
  description = "Managed Identity Client ID"
  sensitive   = true
}