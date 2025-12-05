#Create catalog to house access package
resource "azuread_access_package_catalog" "catalog1" {
  display_name = "rrrz-ctlg-ugv-d-alz-pim"
  description  = "This catalog holds Azure resource roles to be put in access packages"
}

#To add the MI as the catalog owner to create AP
data "azuread_access_package_catalog_role" "catalogrole" {
  display_name = "Catalog Owner"
}

resource "azuread_access_package_catalog_role_assignment" "catalogroleassign" {
  role_id             = data.azuread_access_package_catalog_role.catalogrole.object_id
  principal_object_id = var.mi_objid
  catalog_id          = azuread_access_package_catalog.catalog1.id
}

#wait for changes
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azuread_access_package_catalog_role_assignment.catalogroleassign]
  create_duration = "30s"
}


#Create the catalog association for the groups
resource "azuread_access_package_resource_catalog_association" "catalogassoc" {
  for_each                = var.groups
  catalog_id              = azuread_access_package_catalog.catalog1.id
  resource_origin_id      = each.value.object_id
  resource_origin_system  = "AadGroup"
}

#Create access package
resource "azuread_access_package" "accesspackages" {
  for_each    = var.groups
  catalog_id  = azuread_access_package_catalog.catalog1.id
  display_name = "rrrz-ap-ugv-d-alz-pim-${each.key}"
  description  = "Access package for ${each.key}"
}

resource "azuread_access_package_resource_package_association" "apassoc" {
  for_each                       = azuread_access_package.accesspackages
  access_package_id              = each.value.id
  catalog_resource_association_id = azuread_access_package_resource_catalog_association.catalogassoc[each.key].id
}

#Create the access package policy and access review
resource "azuread_access_package_assignment_policy" "policy1" {
  for_each           = azuread_access_package.accesspackages
  access_package_id  = each.value.id
  display_name       = "${each.key}-policy"
  description        = "Policy for ${each.key} access package"
  duration_in_days   = 365

  requestor_settings {
    requests_accepted = true
    scope_type        = "SpecificDirectorySubjects"
    requestor {
      object_id    = var.admin_group.object_id
      subject_type = "groupMembers"
    }
  }

  approval_settings {
    approval_required               = true
    requestor_justification_required = true
    approval_stage {
      approval_timeout_in_days = 14
      primary_approver {
        object_id    = var.role_owners.object_id
        subject_type = "groupMembers"
      }
    }
  }

  assignment_review_settings {
    enabled                        = true
    review_frequency                = "halfyearly"
    duration_in_days                = 3
    review_type                     = "Reviewers"
    approver_justification_required = true
    access_review_timeout_behavior  = "removeAccess"
    reviewer {
      object_id    = var.role_owners.object_id
      subject_type = "groupMembers"
    }
  }
}