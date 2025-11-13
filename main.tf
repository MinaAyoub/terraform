provider "azurerm" {
  features {}
  use_oidc = true
}

provider "azuread" {
}

##########################
### Roles and Groups #####
##########################
data "azurerm_role_definition" "roles" {
  for_each = toset(var.roles_names)
  name     = each.key
  scope = "${var.subscription_id}"
}

resource "azuread_group" "groups" {
  for_each              = toset(var.roles_names)
  display_name          = "RoleGrp_AzResourceRole_${each.key}"
  description           = "This group is assigned the specific roles specified in name"
  security_enabled      = true
  assignable_to_role    = true
}

# Create the role owner groups for each role
resource "azuread_group" "role_owners" {
  display_name         = "ApproverGrp_AzResourceRoles"
  description          = "This group is the approver and reviewer for the Az resource roles and their access reviews"
  security_enabled     = true
}

#Create the dynamic admin group, this group will contain all admins, and ONLY they will be able to view and request access packages
resource "azuread_group" "admin_group" {
  display_name     = "RequstGrp_AzResourceRoles_AccessPackages"
  description      = "This group will contain admins who able to request access packages containing az resource roles"
  security_enabled = true
}

/*
resource "azurerm_role_assignment" "group_role_assignment" {
  for_each           = data.azurerm_role_definition.roles
  scope              = "/subscriptions/${var.subscription_id}"
  role_definition_id = each.value.id
  principal_id       = azuread_group.groups[each.key].object_id
}
*/
resource "time_static" "start" {}

resource "azurerm_pim_eligible_role_assignment" "example" {
  for_each           = data.azurerm_role_definition.roles
  scope             = "subscriptions/${var.subscription_id}"
  role_definition_id = "${var.subscription_id}/each.value.id"
  principal_id      = azuread_group.groups[each.key].object_id

  schedule {
    start_date_time = time_static.start.rfc3339
    expiration {
     #empty for permanent
    }
  }

  justification = "Permanent eligible assignment for admins"
}


###################################
### Identity Governance Portion ###
###################################

#Create the catalog 
resource "azuread_access_package_catalog" "catalog1" {
  display_name = "CTLG_Azure_Resource_Roles"
  description  = "This catalog holds Azure resource roles to be put in access packages"
}


# Catalog resource association with groups
resource "azuread_access_package_resource_catalog_association" "catalogassoc" {
  for_each                 = azuread_group.groups
  catalog_id               = azuread_access_package_catalog.catalog1.id
  resource_origin_id       = each.value.object_id
  resource_origin_system   = "AadGroup"
}

# Create the access packages
resource "azuread_access_package" "accesspackages" {
  for_each      = azuread_group.groups
  catalog_id    = azuread_access_package_catalog.catalog1.id
  display_name  = "AccessPkg_AzResourceRole_${each.key}"
  description   = "Access package for ${each.key}"
}

# Access package resource association
resource "azuread_access_package_resource_package_association" "apassoc" {
  for_each                          = azuread_access_package.accesspackages
  access_package_id                = each.value.id
  catalog_resource_association_id  = azuread_access_package_resource_catalog_association.catalogassoc[each.key].id
}

# Policy inside the access package
resource "azuread_access_package_assignment_policy" "policy1" {
  for_each          = azuread_access_package.accesspackages
  access_package_id = each.value.id
  display_name      = "${each.key}-policy"
  description       = "Policy for ${each.key} access package"
  duration_in_days  = 180

  requestor_settings {
    requests_accepted = true
    scope_type        = "SpecificDirectorySubjects"

    requestor {
      object_id    = azuread_group.admin_group.object_id
      subject_type = "groupMembers"
    }
  }

  approval_settings {
    approval_required                = true
    requestor_justification_required = true

    approval_stage {
      approval_timeout_in_days = 14

      primary_approver {
        object_id    = azuread_group.role_owners.object_id
        subject_type = "groupMembers"
      }
    }
  }

  assignment_review_settings {
    enabled                        = true
    review_frequency               = "halfyearly"
    duration_in_days               = 3
    review_type                    = "Reviewers"
    approver_justification_required = true
    access_review_timeout_behavior = "removeAccess"

    reviewer {
      object_id = azuread_group.role_owners.object_id
      subject_type = "groupMembers"
    }


  }
}