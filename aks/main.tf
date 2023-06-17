
# data "azurerm_resource_group" "main" {
#   name = var.resource_group_name
# }
resource "tls_private_key" "ssh" {
  count = var.admin_username == null ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "azurerm_kubernetes_cluster" "main" {
  name                = coalesce(var.name, trim("${var.dns_prefix}-aks", "-"))
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  azure_policy_enabled                = var.azure_policy_enabled
  disk_encryption_set_id              = var.disk_encryption_set_id
  http_application_routing_enabled    = var.http_application_routing_enabled
  kubernetes_version                  = var.kubernetes_version
  local_account_disabled              = var.local_account_disabled
  node_resource_group                 = var.node_resource_group
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  open_service_mesh_enabled           = var.open_service_mesh_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  public_network_access_enabled       = var.public_network_access_enabled
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  sku_tier                            = var.sku_tier
  workload_identity_enabled = var.workload_identity_enabled
  tags                                = var.tags

  default_node_pool {
    name                         = var.agents_pool_name
    vm_size                      = var.agents_size
    enable_auto_scaling          = var.enable_auto_scaling
    enable_host_encryption       = var.enable_host_encryption
    enable_node_public_ip        = var.enable_node_public_ip
    max_count                    = var.enable_auto_scaling == true ? var.agents_max_count : null 
    max_pods                     = var.agents_max_pods
    min_count                    = var.enable_auto_scaling == true ? var.agents_min_count : null 
    node_count                   = var.agents_count
    node_labels                  = var.agents_labels
    node_taints                  = var.agents_taints
    only_critical_addons_enabled = var.only_critical_addons_enabled
    orchestrator_version         = var.orchestrator_version
    os_disk_size_gb              = var.os_disk_size_gb
    os_disk_type                 = var.os_disk_type
    os_sku                       = var.os_sku
    pod_subnet_id                = var.pod_subnet_id
    scale_down_mode              = var.scale_down_mode
    tags                         = var.tags
    temporary_name_for_rotation  = var.temporary_name_for_rotation
    type                         = var.agents_type
    ultra_ssd_enabled            = var.ultra_ssd_enabled
    vnet_subnet_id               = var.vnet_subnet_id
    zones                        = var.agents_availability_zones
  }

  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux_enabled ? ["aci_connector_linux"] : []

    content {
      subnet_name = var.aci_connector_linux_subnet_name
    }
  }
  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null || var.api_server_subnet_id != null ? ["api_server_access_profile"] : []

    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
      subnet_id            = var.api_server_subnet_id
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled && var.rbac_aad && var.rbac_aad_managed ? ["rbac"] : []

    content {
      admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      azure_rbac_enabled     = var.rbac_aad_azure_rbac_enabled
      managed                = true
      tenant_id              = var.rbac_aad_tenant_id
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled && var.rbac_aad && !var.rbac_aad_managed ? ["rbac"] : []

    content {
      client_app_id     = var.rbac_aad_client_app_id
      managed           = false
      server_app_id     = var.rbac_aad_server_app_id
      server_app_secret = var.rbac_aad_server_app_secret
      tenant_id         = var.rbac_aad_tenant_id
    }
  }
  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }
  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway_enabled ? ["ingress_application_gateway"] : []

    content {
      gateway_id   = var.ingress_application_gateway_id
      gateway_name = var.ingress_application_gateway_name
      subnet_cidr  = var.ingress_application_gateway_subnet_cidr
      subnet_id    = var.ingress_application_gateway_subnet_id
    }
  }
  dynamic "key_management_service" {
    for_each = var.kms_enabled ? ["key_management_service"] : []

    content {
      key_vault_key_id         = var.kms_key_vault_key_id
      key_vault_network_access = var.kms_key_vault_network_access
    }
  }
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? ["key_vault_secrets_provider"] : []

    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }
  dynamic "linux_profile" {
    for_each = var.admin_username == null ? [] : ["linux_profile"]

    content {
      admin_username = var.admin_username

      ssh_key {
        key_data = replace(coalesce(var.public_ssh_key, tls_private_key.ssh[0].public_key_openssh), "\n", "")
      }
    }
  }
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics != null ? ["monitor_metrics"] : []

    content {
      annotations_allowed = var.monitor_metrics.annotations_allowed
      labels_allowed      = var.monitor_metrics.labels_allowed
    }
  }
  network_profile {
    network_plugin      = var.network_plugin
    dns_service_ip      = var.net_profile_dns_service_ip
    load_balancer_sku   = var.load_balancer_sku
    network_plugin_mode = var.network_plugin_mode
    network_policy      = var.network_policy
    outbound_type       = var.net_profile_outbound_type
    pod_cidr            = var.net_profile_pod_cidr
    service_cidr        = var.net_profile_service_cidr

    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile_enabled && var.load_balancer_sku == "standard" ? ["load_balancer_profile"] : []

      content {
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated
      }
    }
  }
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_enabled ? ["oms_agent"] : []

    content {
      log_analytics_workspace_id = local.log_analytics_workspace.id
    }
  }
  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []

    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }
  dynamic "storage_profile" {
    for_each = var.storage_profile_enabled ? ["storage_profile"] : []

    content {
      blob_driver_enabled         = var.storage_profile_blob_driver_enabled
      disk_driver_enabled         = var.storage_profile_disk_driver_enabled
      disk_driver_version         = var.storage_profile_disk_driver_version
      file_driver_enabled         = var.storage_profile_file_driver_enabled
      snapshot_controller_enabled = var.storage_profile_snapshot_controller_enabled
    }
  }
  lifecycle {
    ignore_changes = [kubernetes_version]

    precondition {
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type != "")
      error_message = "Either `client_id` and `client_secret` or `identity_type` must be set."
    }
    precondition {
      # Why don't use var.identity_ids != null && length(var.identity_ids)>0 ? Because bool expression in Terraform is not short circuit so even var.identity_ids is null Terraform will still invoke length function with null and cause error. https://github.com/hashicorp/terraform/issues/24128
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type == "SystemAssigned") || (var.identity_ids == null ? false : length(var.identity_ids) > 0)
      error_message = "If use identity and `UserAssigned` is set, an `identity_ids` must be set as well."
    }
    precondition {
      condition     = !(var.load_balancer_profile_enabled && var.load_balancer_sku != "standard")
      error_message = "Enabling load_balancer_profile requires that `load_balancer_sku` be set to `standard`"
    }
    precondition {
      condition     = local.automatic_channel_upgrade_check
      error_message = "Either disable automatic upgrades, or specify `kubernetes_version` or `orchestrator_version` only up to the minor version when using `automatic_channel_upgrade=patch`. You don't need to specify `kubernetes_version` at all when using `automatic_channel_upgrade=stable|rapid|node-image`, where `orchestrator_version` always must be set to `null`."
    }
    precondition {
      condition     = var.role_based_access_control_enabled || !var.rbac_aad
      error_message = "Enabling Azure Active Directory integration requires that `role_based_access_control_enabled` be set to true."
    }
    precondition {
      condition     = !(var.kms_enabled && var.identity_type != "UserAssigned")
      error_message = "KMS etcd encryption doesn't work with system-assigned managed identity."
    }
    precondition {
      condition     = !var.workload_identity_enabled || var.oidc_issuer_enabled
      error_message = "`oidc_issuer_enabled` must be set to `true` to enable Azure AD Workload Identity"
    }
    precondition {
      condition     = var.network_plugin_mode != "Overlay" || var.network_plugin == "azure"
      error_message = "When network_plugin_mode is set to Overlay, the network_plugin field can only be set to azure."
    }
    precondition {

      condition     = can(coalesce(var.name, var.dns_prefix))
      error_message = "You must set one of `var.cluster_name` and `var.prefix` to create `azurerm_kubernetes_cluster.main`."
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  count = local.create_analytics_workspace ? 1 : 0

  location            = var.location
  name                = coalesce(var.cluster_log_analytics_workspace_name, trim("${var.dns_prefix}-workspace", "-"))
  resource_group_name = coalesce(var.log_analytics_workspace_resource_group_name, var.resource_group_name)
  retention_in_days   = var.log_retention_in_days
  sku                 = var.log_analytics_workspace_sku
  tags = var.tags

  lifecycle {
    precondition {
      condition     = can(coalesce(var.cluster_log_analytics_workspace_name, var.dns_prefix))
      error_message = "You must set one of `var.cluster_log_analytics_workspace_name` and `var.prefix` to create `azurerm_log_analytics_workspace.main`."
    }
  }
}

locals {
  azurerm_log_analytics_workspace_id   = try(azurerm_log_analytics_workspace.main[0].id, null)
  azurerm_log_analytics_workspace_name = try(azurerm_log_analytics_workspace.main[0].name, null)
}

data "azurerm_log_analytics_workspace" "main" {
  count = local.log_analytics_workspace != null ? 1 : 0

  name = local.log_analytics_workspace.name
  # `azurerm_log_analytics_workspace`'s id format: /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.OperationalInsights/workspaces/workspace1
  resource_group_name = split("/", local.log_analytics_workspace.id)[4]
}

resource "azurerm_log_analytics_solution" "main" {
  count = local.create_analytics_solution ? 1 : 0

  location              = data.azurerm_log_analytics_workspace.main[0].location
  resource_group_name   = data.azurerm_log_analytics_workspace.main[0].resource_group_name
  solution_name         = "ContainerInsights"
  workspace_name        = local.log_analytics_workspace.name
  workspace_resource_id = local.log_analytics_workspace.id
  tags = var.tags

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

resource "azurerm_role_assignment" "acr" {
  for_each = var.attached_acr_id_map

  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  scope                            = each.value
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "network_contributor" {
  for_each = var.create_role_assignment_network_contributor ? local.subnet_ids : []

  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
  scope                = each.value
  role_definition_name = "Network Contributor"
}


