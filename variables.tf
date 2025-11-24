#Single role groups
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

#multi role groups
variable "multi_role_groups" {
  description = "Map of multi-role group names to their assigned roles"
  type        = map(list(string))
  default     = {
    AP_USPOTS_LowRisk = [
      "Reader",
      "Microsoft Sentinel Contributor",
      "Logic App Contributor",
      "Cost Management Reader",
      "Security Reader",
      "Support Request Contributor",
      "Monitoring Reader",
      "Billing Reader",
      "Monitoring Contributor",
      "Workbook Contributor",
      "Log Analytics Reader",
      "Microsoft Sentinel Responder"
    ],
    AP_USPOTS_HighRisk = [
      "Security Reader",
      "Reader",
      "Cost Management Contributor",
      "Microsoft Sentinel Playbook Operator",
      "Logic App Operator",
      "Virtual Machine User Login",
      "Microsoft Sentinel Contributor",
      "Logic App Contributor",
      "Cost Management Reader",
      "Security Reader",
      "Support Request Contributor",
      "Monitoring Reader",
      "Billing Reader",
      "Monitoring Contributor",
      "Workbook Contributor",
      "Log Analytics Reader",
      "Microsoft Sentinel Reader"
    ],
    AP_USPOTS_MostPrivileged = [
      "Owner",
      "Contributor",
      "Security Admin",
      "Reservation Purchaser"
    ]
    # Add more groups as needed
  }
}
