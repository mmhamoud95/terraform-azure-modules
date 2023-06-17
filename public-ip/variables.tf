variable "public_ip" {
  type = any
  default = {}
  description = "create public ip"
}

variable "resource_group_name" {
  type = string
  default = null
  description = "The name of the Resource Group where this Public IP should exist"
}

variable "resource_group_location" {
  type = string
  default = null
  description = "Specifies the supported Azure location where the Public IP should exist"
}

variable "tags" {
  type = map(string)
  default = null
  description = "A mapping of tags to assign to the resource"
}