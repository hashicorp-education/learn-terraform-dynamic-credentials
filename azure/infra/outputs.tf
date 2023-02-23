output "subnet" {
  description = "Address prefixes for subnet"
  value       = azurerm_subnet.example.address_prefixes
}
