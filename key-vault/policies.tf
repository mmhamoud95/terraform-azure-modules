resource "azurerm_key_vault_access_policy" "policies" {
  for_each = { for policies in var.access_policies: policies.tenant_id => policies }
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = each.value.tenant_id
  object_id    = each.value.object_id

  key_permissions = each.value.key_permissions

  secret_permissions = each.value.secret_permissions
  application_id = each.value.application_id
  certificate_permissions = each.value.certificate_permissions
  storage_permissions = each.value.storage_permissions
}