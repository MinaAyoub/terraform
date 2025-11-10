provider "azurerm" {
  features {}
  use_oidc = true
}

provider "azuread" {
}
#testing123
#########################################################
############ Roles, Groups and Access packages ##########
#########################################################
#This section creates the access packages which contain a group that's assigned to a single role

##########################
### Roles and Groups #####
##########################
data "azurerm_role_definition" "roles" {
  for_each = toset(var.roles_names)
  name     = each.key
}

/*
#Create all roles as resources 
resource "azuread_directory_role" "roles" {
  count        = length(var.roles_names)
  display_name = var.roles_names[count.index]
}
*/

#Create the groups to be assigned the roles 
resource "azuread_group" "groups" {
  count                 = length(var.roles_names)
  display_name          = "RoleGrp_AdminRole_${var.roles_names[count.index]}"
  description           = "This group is assigned the specific roles specified in name"
  security_enabled      = true
  assignable_to_role    = true
}

#Create the role owner groups for each role to be used as approvers for access packages 
resource "azuread_group" "role_owners" {
  count                 = length(var.roles_names)
  display_name          = "RoleGrp_Owners_${var.roles_names[count.index]}"
  description           = "This group owns the specified role, owners will be reponsible for approving access"
  security_enabled      = true
  assignable_to_role    = true
}


#Create the dynamic admin group, this group will contain all admins, and ONLY they will be able to view and request access packages
resource "azuread_group" "admin_group" {
  display_name     = "Admins_AccessPackageRoleRequest"
  description      = "This group will contain admins able to request access packages"
  security_enabled = true
}


# Assign roles to groups at subscription scope
resource "azurerm_role_assignment" "group_role_assignment" {
  count              = length(var.roles_names)
  scope              = "/subscriptions/${var.subscription_id}"
  role_definition_id = data.azurerm_role_definition.roles.id
  principal_id       = azuread_group.groups[count.index].object_id
}


/*
#Create eligible role assignments for groups in access packages
resource "azuread_directory_role_eligibility_schedule_request" "elassign" {
  count              = length(var.roles_names)
 
  role_definition_id = (azuread_directory_role.roles[count.index]).template_id
  principal_id       = (azuread_group.groups[count.index]).id
  directory_scope_id = "/"
  justification      = "Given through access package"
}
*/

###################################
### Identity Governance Portion ###
###################################

#Create the catalog 
resource "azuread_access_package_catalog" "catalog1" {
  display_name = "CTLG_EntraIDRoles_PIM"
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
  display_name = "AccessPkg_AdminRole_${var.roles_names[count.index]}"
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

/*
#############################################################
###################### Multi Role groups ####################
#############################################################

#Create the groups for PIM for groups based on the map variable keys
resource "azuread_group" "pimgroups" {
  for_each = var.role_map

  display_name          = "MultiRoleGrp_AdminGrp_${each.key}"
  description           = "This group is assigned the multiple admin roles"
  security_enabled      = true
  assignable_to_role    = true
}


#Create the role owner groups for each MULTI role group to be used as approvers for access packages 
resource "azuread_group" "multi_role_owners" {
  for_each = var.role_map

  display_name          = "MultiRoleGrp_Owners_${each.key}"
  security_enabled      = true
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

locals {
  role_keys = keys(var.role_map)
}

#Create eligible role assignments for groups in access packages
resource "azuread_directory_role_eligibility_schedule_request" "elassignmulti" {
  for_each = { for i in local.flattened_map : "${i.group_name}-${i.role_id}" => i }

  role_definition_id = each.value.role_id
  principal_id       = azuread_group.pimgroups[each.value.group_name].object_id
  directory_scope_id = "/"
  justification      = "Given through access package "
}


#########################################################
### Identity Governance Portion for Multi role groups ###
#########################################################


#Create the catalog resource association with the groups 
resource "azuread_access_package_resource_catalog_association" "multi_catalogassoc" {
  #for_each               = var.role_map
  count                  = length(var.role_map)
  catalog_id             = azuread_access_package_catalog.catalog1.id
  resource_origin_id     = azuread_group.pimgroups[local.role_keys[count.index]].id
  resource_origin_system = "AadGroup"
}


#Create the access packages
resource "azuread_access_package" "multi_accesspackages" {
  count        = length(var.role_map)
  catalog_id   = azuread_access_package_catalog.catalog1.id
  display_name = "AccessPkg_MultiAdminRoles_${local.role_keys[count.index]}_GROUP"
  description  = "Access package for ${local.role_keys[count.index]}_GROUP"
}


#Create the access package resource association
resource "azuread_access_package_resource_package_association" "multi_apassoc" {
  count                           = length(var.role_map)
  access_package_id               = (azuread_access_package.multi_accesspackages[count.index]).id
  catalog_resource_association_id = (azuread_access_package_resource_catalog_association.multi_catalogassoc[count.index]).id
}


#Create the policy inside the access package
resource "azuread_access_package_assignment_policy" "multi_policy1" {
  count             = length(var.role_map)
  access_package_id = (azuread_access_package.multi_accesspackages[count.index]).id
  display_name      = "${local.role_keys[count.index]}-policy"
  description       = "Policy for ${local.role_keys[count.index]} access package"
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
        object_id    = azuread_group.multi_role_owners[local.role_keys[count.index]].object_id
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

*/