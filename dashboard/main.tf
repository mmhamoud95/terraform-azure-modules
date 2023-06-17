resource "azurerm_portal_dashboard" "dash" {
  for_each = { for d in var.dashboards : d.name => d }

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  dashboard_properties = templatefile(each.value.tpl_file, each.value.variables)

  tags = var.tags
}