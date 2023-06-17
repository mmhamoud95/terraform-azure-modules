resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each = var.node_pools

  kubernetes_cluster_id         = azurerm_kubernetes_cluster.main.id
  name                          = "${each.value.name}${substr(md5(jsonencode(each.value)), 0, 4)}"
  vm_size                       = each.value.vm_size
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  custom_ca_trust_enabled       = each.value.custom_ca_trust_enabled
  enable_auto_scaling           = each.value.enable_auto_scaling
  enable_host_encryption        = each.value.enable_host_encryption
  enable_node_public_ip         = each.value.enable_node_public_ip
  eviction_policy               = each.value.eviction_policy
  fips_enabled                  = each.value.fips_enabled
  host_group_id                 = each.value.host_group_id
  kubelet_disk_type             = each.value.kubelet_disk_type
  max_count                     = each.value.max_count
  max_pods                      = each.value.max_pods
  message_of_the_day            = each.value.message_of_the_day
  min_count                     = each.value.min_count
  mode                          = each.value.mode
  node_count                    = each.value.node_count
  node_labels                   = each.value.node_labels
  node_public_ip_prefix_id      = each.value.node_public_ip_prefix_id
  node_taints                   = each.value.node_taints
  orchestrator_version          = each.value.orchestrator_version
  os_disk_size_gb               = each.value.os_disk_size_gb
  os_disk_type                  = each.value.os_disk_type
  os_sku                        = each.value.os_sku
  os_type                       = each.value.os_type
  pod_subnet_id                 = each.value.pod_subnet_id
  priority                      = each.value.priority
  proximity_placement_group_id  = each.value.proximity_placement_group_id
  scale_down_mode               = each.value.scale_down_mode
  spot_max_price                = each.value.spot_max_price
  tags = each.value.tags
  ultra_ssd_enabled = each.value.ultra_ssd_enabled
  vnet_subnet_id    = each.value.vnet_subnet_id
  workload_runtime  = each.value.workload_runtime
  zones             = each.value.zones

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      node_taints,
      eviction_policy
    ]
    replace_triggered_by = [
      null_resource.pool_name_keeper[each.key],
    ]

    precondition {
      condition     = var.agents_type == "VirtualMachineScaleSets"
      error_message = "Multiple Node Pools are only supported when the Kubernetes Cluster is using Virtual Machine Scale Sets."
    }
    precondition {
      condition     = can(regex("[a-z0-9]{1,8}", each.value.name))
      error_message = "A Node Pools name must consist of alphanumeric characters and have a maximum lenght of 8 characters (4 random chars added)"
    }
    precondition {
      condition     = var.network_plugin_mode != "Overlay" || each.value.os_type != "Windows"
      error_message = "Windows Server 2019 node pools are not supported for Overlay and Windows support is still in preview"
    }
    precondition {
      condition     = var.network_plugin_mode != "Overlay" || !can(regex("^Standard_DC[0-9]+s?_v2$", each.value.vm_size))
      error_message = "With with Azure CNI Overlay you can't use DCsv2-series virtual machines in node pools. "
    }
  }
}

resource "null_resource" "pool_name_keeper" {
  for_each = var.node_pools

  triggers = {
    pool_name = each.value.name
  }
}