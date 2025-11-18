variable "roles_names" {
  type = list(string)
  default = [
    "Reader",
    "Key Vault Reader",
    "Logic App Operator",
    "Virtual Machine User Login",
    "Microsoft Sentinel Playbook Operator",
    "Microsoft Sentinel Reader"
  ]
}
variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID where roles will be assigned"
  sensitive   = true
}
