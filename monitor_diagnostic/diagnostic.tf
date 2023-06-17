
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = {for i,k in var.diagnostics: i => k}
  name               = each.value.name
  target_resource_id = each.value.target_resource_id
  storage_account_id = lookup(each.value, "storage_account_id",null)
  eventhub_name      = lookup(each.value, "eventhub_name", null)
  eventhub_authorization_rule_id = lookup(each.value, "eventhub_authorization_rule_id", null)
  log_analytics_workspace_id = lookup(each.value, "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(each.value, "log_analytics_destination_type", null)
  partner_solution_id = lookup(each.value, "partner_solution_id", null)

  dynamic "enabled_log" {
    for_each = can(each.value.enabled_log) ? { for i, k in each.value.enabled_log : i => k } : {}
    content {
      category = enabled_log.value.category
      retention_policy {
        enabled = enabled_log.value.retention_policy_days != null ? true : false
        days = enabled_log.value.retention_policy_days
      }
    }
  }
  dynamic "metric" {
    for_each = can(each.value.metric) ? { for i, k in each.value.metric : i => k } : {}
    content {
      category = metric.value.category
      retention_policy {
        enabled = metric.value.retention_policy_days != null ? true : false
        days = metric.value.retention_policy_days
      }
    }
  }


}