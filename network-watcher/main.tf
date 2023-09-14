resource "azurerm_network_watcher" "watcher" {
  for_each = {for watcher in var.network_watcher: watcher.name => watcher }
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "sg" {
  for_each = {for watcher in var.network_watcher: watcher.name => watcher }
  name                = "${each.value.name}-sg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_account" "sa" {
  for_each = {for watcher in var.network_watcher: watcher.name => watcher }
  name                = "${each.value.name}-sa"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
}

resource "azurerm_log_analytics_workspace" "workspace" {
  for_each = {for watcher in var.network_watcher: watcher.name => watcher }
  name                = "${each.value.name}-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_network_watcher_flow_log" "flow_log" {
  for_each = {for watcher in var.network_watcher: watcher.name => watcher }
  network_watcher_name = azurerm_network_watcher.watcher.name
  resource_group_name  = var.resource_group_name
  name                 = "${each.value.name}-log"

  network_security_group_id = azurerm_network_security_group.sg.id
  storage_account_id        = azurerm_storage_account.sa.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.workspace.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.workspace.location
    workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    interval_in_minutes   = 10
  }
}