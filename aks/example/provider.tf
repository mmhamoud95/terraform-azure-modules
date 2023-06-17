# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "3.60.0"
#     }
#     kubectl = {
#       source = "gavinbunney/kubectl"
#       version = "1.14.0"
#     }
#     helm = {
#       source = "hashicorp/helm"
#       version = "2.6.0"
#     }
#     kubernetes = {
#       source = "hashicorp/kubernetes"
#       version = "2.13.1"
#     }
#   }
# }

provider "azurerm" {
  features {}
  tenant_id = "8b9cef57-e6fc-499a-9ff8-45c1cf0dd671"
  subscription_id = "44fb95fb-b80a-4f3a-b211-5e7e67ce957a"

}

# provider "kubectl" {
#     client_key = local.client_key
#     client_certificate = local.client_certificate
#     cluster_ca_certificate = local.cluster_ca_certificate
#     host = local.host
# }
# provider "helm" {
#   kubernetes {
#     client_key = local.client_key
#     client_certificate = local.client_certificate
#     cluster_ca_certificate = local.cluster_ca_certificate
#     host = local.host
#     username = local.username
#     password = local.password
#   }
# }
# provider "kubernetes" {
#     client_key = local.client_key
#     client_certificate = local.client_certificate
#     cluster_ca_certificate = local.cluster_ca_certificate
#     host = local.host
#     username = local.username
#     password = local.password
# }

