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
