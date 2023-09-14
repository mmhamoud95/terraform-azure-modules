resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  resource_group_name = var.resource_group_name
  name                = local.postgresql_flexible_server_name
  location            = var.location

  sku_name   = join("_", [lookup(local.tier_map, var.tier, "GeneralPurpose"), "Standard", var.size])
  storage_mb = var.storage_mb
  version    = var.postgresql_version

  zone = var.zone

  dynamic "high_availability" {
    for_each = var.standby_zone != null && var.tier != "Burstable" ? toset([var.standby_zone]) : toset([])

    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = high_availability.value
    }
  }

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? toset([var.maintenance_window]) : toset([])

    content {
      day_of_week  = lookup(maintenance_window.value, "day_of_week", 0)
      start_hour   = lookup(maintenance_window.value, "start_hour", 0)
      start_minute = lookup(maintenance_window.value, "start_minute", 0)
    }
  }

  private_dns_zone_id = var.private_dns_zone_id
  delegated_subnet_id = var.delegated_subnet_id

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.private_dns_zone_id != null && var.delegated_subnet_id != null || var.private_dns_zone_id == null && var.delegated_subnet_id == null
      error_message = "var.private_dns_zone_id and var.delegated_subnet_id should either both be set or none of them."
    }
  }

  depends_on = [var.vm_depends_on]
}

resource "azurerm_postgresql_flexible_server_database" "postgresql_flexible_db" {
  for_each = var.databases

  name      = var.use_caf_naming_for_databases ? data.azurecaf_name.postgresql_flexible_dbs[each.key].result : each.key
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  charset   = each.value.charset
  collation = each.value.collation

  depends_on = [var.vm_depends_on]

}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_config" {
  for_each  = var.postgresql_configurations
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  value     = each.value

  depends_on = [var.vm_depends_on]
}

data "azurerm_monitor_diagnostic_categories" "server" {
  resource_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}

resource "azurerm_monitor_diagnostic_setting" "server" {
  count = var.diagnostics != null ? 1 : 0

  name                       = "${local.postgresql_flexible_server_name}-diagnostics"
  target_resource_id         = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  log_analytics_workspace_id = var.diagnostics.log_analytics_workspace_id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.server.log_category_types
    content {
      category = log.value
      enabled  = contains(var.diagnostics.logs, "all") || contains(var.diagnostics.logs, log.value)

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.server.metrics
    content {
      category = metric.value
      enabled  = contains(var.diagnostics.metrics, "all") || contains(var.diagnostics.metrics, metric.value)

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }
}