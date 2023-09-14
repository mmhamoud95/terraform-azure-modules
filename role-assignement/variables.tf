variable "roles" {
  type = map(object({
    name  = optional(string)
    scope = optional(string)
    role_definition_name = optional(string)
    principal_id = string
    skip_service_principal_aad_check = optional(string)
    }))
  default = {}
}

