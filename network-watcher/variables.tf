variable "network_watcher" {
  type        = map(string)
  default     = {}
  description = "map to create network watcher and configure"
  #network_watcher = {
  #  name = ""
  #   }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network."
}

variable "location" {
  type        = string
  description = "The location/region where the virtual network is created."
}