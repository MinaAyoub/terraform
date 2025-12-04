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

variable "mi_client_id" {
  type        = string
  description = "Managed Identity Client ID"
  sensitive   = true
}