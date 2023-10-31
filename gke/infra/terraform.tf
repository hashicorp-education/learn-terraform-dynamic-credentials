terraform {
  cloud {
    organization = "k8s-dynamic-creds"

    workspaces {
      name = "learn-terraform-dynamic-credentials"
    }
  }
}
