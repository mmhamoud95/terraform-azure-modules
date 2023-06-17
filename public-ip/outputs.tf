output "public_ip_id" {
  value = {for i,k in azurerm_public_ip.this: i => k.id}
}
output "ip_address" {
    value = {for i,k in azurerm_public_ip.this: i => k.ip_address}
}