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
    LowRisk_USPOTS = [
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
    HighRisk_USPOTS = [
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
    MostPrivileged_USPOTS = [
      "Owner",
      "Contributor",
      "Security Admin",
      "Reservation Purchaser"
    ]
    # Add more groups as needed
  }
}
