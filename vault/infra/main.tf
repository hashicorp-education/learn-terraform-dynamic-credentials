provider "vault" {
  address = var.vault_url
}

resource "vault_mount" "example" {
  namespace = "admin"

  path    = "example"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_kv_secret_v2" "example" {
  mount               = vault_mount.example.path

  name                = "unsecret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      foo = "bar"
    }
  )
}
