# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "google_container_cluster" "upstream" {
  provider = google-beta
  name     = var.cluster_name
  location = var.cluster_location
}

data "google_client_config" "provider" {
  provider = google-beta
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.upstream.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.upstream.master_auth[0].cluster_ca_certificate,
  )
}

import {
  // The name of this resource is hardcoded by GKE as described in:
  // https://cloud.google.com/kubernetes-engine/docs/how-to/oidc#configuring_on_a_cluster
  //
  id = "apiVersion=authentication.gke.io/v2alpha1,kind=ClientConfig,namespace=kube-public,name=default"
  to = kubernetes_manifest.oidc_conf
}

resource "kubernetes_manifest" "oidc_conf" {
  manifest = {
    apiVersion = "authentication.gke.io/v2alpha1"
    kind       = "ClientConfig"
    metadata = {
      name      = "default"
      namespace = "kube-public"
    }
    spec = {
      authentication = [
        {
          name = data.google_container_cluster.upstream.name
          oidc = {
            clientID    = var.tfc_kubernetes_audience
            issuerURI   = var.tfc_hostname
            userClaim   = "sub"
            groupsClaim = var.rbac_group_oidc_claim
          }
        }
      ]
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "oidc_role" {
  metadata {
    name = "odic-identity"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.rbac_group_cluster_role
  }

  // Option A - Bind RBAC roles to groups
  //
  // Groups are extracted from the token claim designated by 'rbac_group_oidc_claim'
  //
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.tfc_organization_name
  }

  // Option B - Bind RBAC roles to user indentities
  //
  // Users are extracted from the 'sub' token claim.
  // Plan and apply phases get assigned different users identities.
  // For TFC tokens, the format of the user id is always the one described bellow.
  //
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:plan"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:apply"
  }
}
