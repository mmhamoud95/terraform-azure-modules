

resource "azurerm_role_assignment" "role_assignment" {
    for_each = {for role in var.roles: role.role_definition_name => role}
    name                             = each.value.name 
    scope                            = each.value.scope
    role_definition_name             = each.value.role_definition_name
    principal_id                     = each.value.principal_id
    skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}