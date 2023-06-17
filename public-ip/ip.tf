
resource "azurerm_public_ip" "this" {
  for_each = {for i,k in var.public_ip: i => k}
  name                = try(each.value.name, each.key)
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = each.value.allocation_method
  zones = lookup(each.value, "zones", null)
  ddos_protection_mode = lookup(each.value, "ddos_protection_mode", null)
  ddos_protection_plan_id = lookup(each.value, "ddos_protection_plan_id", null)
  domain_name_label = lookup(each.value, "domain_name_label", null)
  edge_zone = lookup(each.value, "edge_zone", null)
  idle_timeout_in_minutes = lookup(each.value,"idle_timeout_in_minutes", null)
  ip_tags = lookup(each.value, "ip_tags",null)
  ip_version = lookup(each.value,"ip_version", null)
  public_ip_prefix_id = lookup(each.value, "public_ip_prefix_id", null)
  reverse_fqdn = lookup(each.value, "reverse_fqdn", null)
  sku = lookup(each.value, "sku", "Basic")
  sku_tier = lookup(each.value, "sku_tier","Regional" )
  tags = var.tags
}
