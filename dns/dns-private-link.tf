resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count = var.create_dns_zone ? 0 : (var.public_dns_zone ? 0 : length(var.dns_private_link))
  name                  = var.dns_private_link[count.index].name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone_private[0].id
  virtual_network_id    = var.dns_private_link[count.index].virtual_network_id
}