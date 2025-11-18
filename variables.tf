variable "roles_names" {
  type = list(string)
  default = [
    "Logic App Operator"
  ]
}
variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID where roles will be assigned"
  sensitive   = true
}


variable "multi_role_groups" {
  description = "Map of multi-role group names to their assigned roles"
  type        = map(list(string))
  default     = {
    US_POTS_LowRisk = [
      "Reader",
      "Key Vault Reader"
    ],
    US_POTS_HighRisk = [
      "Logic App Operator",
      "Virtual Machine User Login"
    ]
    # Add more groups as needed
  }
}
