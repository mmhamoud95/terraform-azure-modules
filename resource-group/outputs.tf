output "resource_group_location" {
  value       = try(azurerm_resource_group.this[0].location, data.azurerm_resource_group.this[0].location)
  description = "la location de la ressource groupe"
}
output "resource_group_name" {
  value       = try(azurerm_resource_group.this[0].name, data.azurerm_resource_group.this[0].name)
  description = "le nom de la ressource groupe"
}
output "resource_group_id" {
  value = try(azurerm_resource_group.this[0].id, data.azurerm_resource_group.this[0].id)
  description = "ID ressource groupe"
}

