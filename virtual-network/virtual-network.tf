
resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  bgp_community       = var.bgp_community


  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [""] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  
}