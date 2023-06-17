resource "azurerm_subnet" "subnets" {
  for_each                                      = { for subnet in var.subnets : subnet.name => subnet }
  name                                          = each.value.name
  resource_group_name                           = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [""] : []
    content {
      name = each.value.delegation
      service_delegation {
        name    = each.value.delegation
        actions = formatlist("Microsoft.Network/%s", local.service_delegation_actions[each.value.delegation])
      }
    }
  }
}