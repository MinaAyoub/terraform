
#This variable holds the values for the PIM for groups, the group names and the roles to be added 
variable "role_map" {
  type = map(list(string))
  default = {
    "IdentityAdministrators00000" = ["fe930be7-5e62-47db-91af-98c3a49a38b1", 
                                  "966707d0-3269-4727-9be2-8c3a10f19b9d", 
                                  "fdd7a751-b60b-444a-984c-02652fe8fa1c", 
                                  "45d8d3c5-c802-45c6-b32a-1d70b5e1e86e", 
                                  "c4e39bd9-1100-46d3-8c65-fb160da0071f", 
                                  "e8611ab8-c189-46e8-94e1-60213ab1f814", 
                                  "9360feb5-f418-4baa-8175-e2a00bac4301", 
                                  "6e591065-9bad-43ed-90f3-e9424366d2f0", 
                                  "be2f45a1-457d-42af-a067-6ec1fa63bc45", 
                                  "0526716b-113d-4c15-b2c8-68e3c22b9f80"]
    "InfraAdministrators" = ["fe930be7-5e62-47db-91af-98c3a49a38b1",
                                "17315797-102d-40b4-93e0-432062caca18",
                                "194ae4cb-b126-40b2-bd5b-6091b380977d",
                                "158c047a-c907-4556-b7ef-446551a6b5f7",
                                "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9",
                                "f2ef992c-3afb-46b9-b7cf-a126ee74c451",
                                "e3973bdf-4987-49ae-837a-ba8e231c7286",
                                "892c5842-a9a6-463a-8041-72aa08ca3cf6"]
    "SecurityAdministrators" = ["194ae4cb-b126-40b2-bd5b-6091b380977d",
                                  "892c5842-a9a6-463a-8041-72aa08ca3cf6",
                                  "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9",
                                  "45d8d3c5-c802-45c6-b32a-1d70b5e1e86e",
                                  "5d6b6bb7-de71-4623-b4af-96380a352509"]
     }
}

#Variables to hold all the names to be used to generate everything else, adding a new value here will create a new group and access package etc
variable "roles_names" {
  type    = list(string)
  default = [
              "Application Administrator", 
              "Application Developer", 
              "Billing Administrator", 
              "Global Administrator", 
              "Global Reader", 
              "Groups Administrator", 
              "Security Administrator", 
              "Security Operator", 
              "Security Reader", 
              "User Administrator"
]
}



