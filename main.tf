provider "azurerm" {
  features {}
  use_oidc = true
}

provider "azuread" {
}


#Create the groups for PIM for groups based on the map variable keys
resource "azuread_group" "pimgroups" {
  for_each = var.role_map

  display_name          = each.key
  security_enabled      = true
  assignable_to_role    = true
}


#Flatten data in variable to create all roles for PIM for groups
locals {
  flattened_map = flatten([
    for k, v in var.role_map : [
      for id in v : {
        group_name = k
        role_id    = id
      }
    ]
  ])
}

/*
#Create roles assignment for PIM for groups, will assign the roles to the group id based on key values in the map variable
resource "azuread_directory_role_assignment" "pag_assignments" {
  for_each = { for i in local.flattened_map : "${i.group_name}-${i.role_id}" => i }

  role_id             = each.value.role_id
  principal_object_id = azuread_group.pimgroups[each.value.group_name].object_id
}
*/

#Create eligible role assignments for groups in access packages
resource "azuread_directory_role_eligibility_schedule_request" "elassignmulti" {
  for_each = { for i in local.flattened_map : "${i.group_name}-${i.role_id}" => i }

  role_definition_id = each.value.role_id
  principal_id       = azuread_group.pimgroups[each.value.group_name].object_id
  directory_scope_id = "/"
  justification      = "Given through access package"
}



#########################################################
############ Roles, Groups and Access packages ##########
#########################################################
#This section creates the access packages which contain a group that's assigned to a single role

##########################
### Roles and Groups #####
##########################

#Create all roles as resources 
resource "azuread_directory_role" "roles" {
  count        = length(var.roles_names)
  display_name = var.roles_names[count.index]
}

#Create the groups to be assigned the roles 
resource "azuread_group" "groups" {
  count                 = length(var.roles_names)
  display_name          = "RLGRP_AdminRole_${var.roles_names[count.index]}"
  security_enabled      = true
  assignable_to_role    = true
}

#Create the role owner groups for each role to be used as approvers for access packages 
resource "azuread_group" "role_owners" {
  count                 = length(var.roles_names)
  display_name          = "RoleOwners_${var.roles_names[count.index]}"
  security_enabled      = true
  assignable_to_role    = true
}

#Create the dynamic admin group, this group will contain all admins, and ONLY they will be able to view and request access packages
resource "azuread_group" "admin_group" {
  display_name     = "Admins_AccessPackageRequest"
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.userPrincipalName -contains \".ads\""
  }
}

#Create eligible role assignments for groups in access packages
resource "azuread_directory_role_eligibility_schedule_request" "elassign" {
  count                 = length(var.roles_names)
 
  role_definition_id = (azuread_directory_role.roles[count.index]).template_id
  principal_id       = (azuread_group.groups[count.index]).id
  directory_scope_id = "/"
  justification      = "Given through access package"
}


###################################
### Identity Governance Portion ###
###################################

#Create the catalog 
resource "azuread_access_package_catalog" "catalog1" {
  display_name = "CL_EntraIDRoles_PIM"
  description  = "This catalog holds Azure AD roles to be put in access packages"
}

#Create the catalog resource association with the groups 
resource "azuread_access_package_resource_catalog_association" "catalogassoc" {
  count                  = length(var.roles_names)
  catalog_id             = azuread_access_package_catalog.catalog1.id
  resource_origin_id     = (azuread_group.groups[count.index]).id
  resource_origin_system = "AadGroup"
}

#Create the access packages
resource "azuread_access_package" "accesspackages" {
  count        = length(var.roles_names)
  catalog_id   = azuread_access_package_catalog.catalog1.id
  display_name = "AP_EntraID_${var.roles_names[count.index]}"
  description  = "Access package for ${var.roles_names[count.index]}"
}

#Create the access package resource association
resource "azuread_access_package_resource_package_association" "apassoc" {
  count                           = length(var.roles_names)
  access_package_id               = (azuread_access_package.accesspackages[count.index]).id
  catalog_resource_association_id = (azuread_access_package_resource_catalog_association.catalogassoc[count.index]).id
}

#Create the policy inside the access package
resource "azuread_access_package_assignment_policy" "policy1" {
  count             = length(var.roles_names)
  access_package_id = (azuread_access_package.accesspackages[count.index]).id
  display_name      = "${var.roles_names[count.index]}-policy"
  description       = "Policy for ${var.roles_names[count.index]} access package"
  duration_in_days  = 180

  requestor_settings {
    requests_accepted = true
    scope_type = "SpecificDirectorySubjects"

    requestor {
      object_id = azuread_group.admin_group.object_id
      subject_type = "groupMembers"
    }

  }

  approval_settings {
    approval_required = true
    requestor_justification_required = true 
  
    approval_stage {
      approval_timeout_in_days = 14

      primary_approver {
        object_id    = azuread_group.role_owners[count.index].object_id
        subject_type = "groupMembers"
      }
    }
  }

  assignment_review_settings {
    enabled                        = true
    review_frequency               = "quarterly"
    duration_in_days               = 3
    review_type                    = "Self"
    access_review_timeout_behavior = "removeAccess"
  }
}
