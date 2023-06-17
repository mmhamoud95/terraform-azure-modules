resource "azurerm_resource_group" "example" {
  name     = "example-test-aks"
  location = "West Europe"
}

resource "random_id" "prefix" {
  byte_length = 8
}
resource "azurerm_virtual_network" "test" {
  address_space       = ["10.52.0.0/16"]
  location            = azurerm_resource_group.example.location
  name                = "${random_id.prefix.hex}-vn"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "test" {
  address_prefixes                               = ["10.52.0.0/24"]
  name                                           = "${random_id.prefix.hex}-sn"
  resource_group_name                            = azurerm_resource_group.example.name
  virtual_network_name                           = azurerm_virtual_network.test.name
}

locals {
  resource_group = {
    name = azurerm_resource_group.example.name
    location = azurerm_resource_group.example.location
    }
  nodes = {
    for i in range(1) : "worker${i}" => {
      name           = substr("worker${i}${random_id.prefix.hex}", 0, 8)
      vm_size        = "Standard_D2s_v3"
      node_count     = 1
      priority       = "Spot"
    #   enable_auto_scaling = true
    #   max_count = 2
    #   min_count = 1
      vnet_subnet_id = azurerm_subnet.test.id
    }
  }
}

module "yourname" {
  source = "../"
  resource_group_name = local.resource_group.name
  location = local.resource_group.location
  name = "cluster-test"
  dns_prefix = "prefix-${random_id.prefix.hex}"
  os_disk_size_gb               = 60
  sku_tier                      = "Standard"
  rbac_aad                      = false
  agents_count = 1
  vnet_subnet_id                = azurerm_subnet.test.id
  node_pools                    = local.nodes
}