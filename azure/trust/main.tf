# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {}

resource "azuread_application" "tfc_application" {
  display_name = "tfc-application"
}

resource "azuread_service_principal" "tfc_service_principal" {
  application_id = azuread_application.tfc_application.application_id
}

resource "azuread_application_federated_identity_credential" "tfc_federated_credential_plan" {
  application_object_id = azuread_application.tfc_application.object_id
  display_name          = "my-tfc-federated-credential-plan"
  audiences             = [var.tfc_azure_audience]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:plan"
}

resource "azuread_application_federated_identity_credential" "tfc_federated_credential_apply" {
  application_object_id = azuread_application.tfc_application.object_id
  display_name          = "my-tfc-federated-credential-apply"
  audiences             = [var.tfc_azure_audience]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:apply"
}

resource "azurerm_role_assignment" "tfc_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = "Contributor"
}
