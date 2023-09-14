output "role_assignments" {
    value = {for role in azurerm_role_assignment.role_assignment: role.role_definition_name => role}
    description = "Displays the full output of the role assignment in a map format."
    
}


