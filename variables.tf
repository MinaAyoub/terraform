
#This variable holds the values for the PIM for groups, the group names and the roles to be added 
variable "role_map" {
  type = map(list(string))
  default = {
    "RLGRP_UAT_IdentityAdmins" = ["fe930be7-5e62-47db-91af-98c3a49a38b1", 
                                  "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9", 
                                  "7be44c8a-adaf-4e2a-84d6-ab2649e08a13", 
                                  "fdd7a751-b60b-444a-984c-02652fe8fa1c", 
                                  "fdd7a751-b60b-444a-984c-02652fe8fa1c", 
                                  "c4e39bd9-1100-46d3-8c65-fb160da0071f", 
                                  "7be44c8a-adaf-4e2a-84d6-ab2649e08a13", 
                                  "9360feb5-f418-4baa-8175-e2a00bac4301",
                                  "3edaf663-341e-4475-9f94-5c398ef6c070", 
                                  "3edaf663-341e-4475-9f94-5c398ef6c070", 
                                  "0526716b-113d-4c15-b2c8-68e3c22b9f80", 
                                  "5b784334-f94b-471a-a387-e7219fc49ca2"]
    "RLGRP_UAT_InfraAdmins" = ["fe930be7-5e62-47db-91af-98c3a49a38b1", 
                                "17315797-102d-40b4-93e0-432062caca18", 
                                "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3", 
                                "fe930be7-5e62-47db-91af-98c3a49a38b1", 
                                "158c047a-c907-4556-b7ef-446551a6b5f7", 
                                "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9", 
                                "b0f54661-2d74-4c50-afa3-1ec803f12efe", 
                                "fdd7a751-b60b-444a-984c-02652fe8fa1c", 
                                "e3973bdf-4987-49ae-837a-ba8e231c7286", 
                                "8329153b-31d0-4727-b945-745eb3bc5f31", 
                                "892c5842-a9a6-463a-8041-72aa08ca3cf6"]
    "RLGRP_UAT_SecurityAdmins" = ["fe930be7-5e62-47db-91af-98c3a49a38b1", 
                                  "158c047a-c907-4556-b7ef-446551a6b5f7", 
                                  "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9", 
                                  "fdd7a751-b60b-444a-984c-02652fe8fa1c", 
                                  "3d6c7d3e-0c4e-4d3e-8b7b-1a8b1b1b1b1b"]
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



