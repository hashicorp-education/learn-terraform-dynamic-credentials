output "test_configmap" {
  value = kubernetes_config_map.test.data
}