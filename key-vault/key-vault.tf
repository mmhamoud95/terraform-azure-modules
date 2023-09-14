resource "azurerm_key_vault" "vault" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku_name                        = lower(var.sku_name)
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    iterator = acl
    content {
      bypass                     = acl.value.bypass
      default_action             = acl.value.default_action
      ip_rules                   = acl.value.ip_rules
      virtual_network_subnet_ids = acl.value.virtual_network_subnet_ids
    }
  }

  dynamic "contact" {
    for_each = var.contacts
    content {
      email = contact.value.email
      name  = lookup(contact.value, "name", null)
      phone = lookup(contact.value, "phone", null)
    }
  }

  tags = var.tags
}

resource "azurerm_key_vault_key" "vault" {
  for_each        = { for key in var.keys : key.name => key }
  key_vault_id    = azurerm_key_vault.vault.id
  name            = each.value.name
  key_type        = each.value.key_type
  key_size        = lookup(each.value, "key_size", null)
  curve           = lookup(each.value, "curve", null)
  key_opts        = lookup(each.value, "key_opts", "") == "" ? null : split(",", each.value.key_opts)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)
}

resource "azurerm_key_vault_secret" "vault" {
  for_each        = { for secret in var.secrets : secret.name => secret }
  key_vault_id    = azurerm_key_vault.vault.id
  name            = each.value.name
  value           = each.value.value
  content_type    = lookup(each.value, "content_type", null)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)
}