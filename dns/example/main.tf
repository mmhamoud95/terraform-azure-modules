module "dns" {
  

  zone_name           = "az.domain.net"
  resource_group_name = "rg-monitoring01"

  create_dns_zone     = true

  a_records   = [
    {
      name    = "www"
      records = ["10.10.10.1"]
      ttl     = 3600
    },
    {
      name    = "myshop"
      records = ["10.10.10.2"]
      ttl     = 3600
    }
  ]

  soa_record = {
    email     = "admin"
    host_name = "ns1-03.azure-dns.com."

    tags = {
      "env"   = "prod"
      "owner" = "scalair"
    }
  }
}