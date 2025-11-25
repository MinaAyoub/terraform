
variable "group_name" {
  type        = string
  description = "Name of the Azure AD group to create"
}

variable "role_names" {
  type        = list(string)
  description = "List of Azure role names to assign to the group"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type = string
}