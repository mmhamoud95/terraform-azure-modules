output "network_watcher" {
  value = {for watcher in azurerm_network_watcher.watcher : watcher.name => watcher }
}

output "network_watcher_log" {
  value = {for watcher in azurerm_network_watcher_flow_log.flow_log : watcher.name => watcher }
}