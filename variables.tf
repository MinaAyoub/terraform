#Variables to hold all the names to be used to generate everything else, adding a new value here will create a new group and access package etc
variable "roles_names" {
  type    = list(string)
  default = [
              "Reader"
]
}


#sub id
variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID where roles will be assigned"
  sensitive = true
}


