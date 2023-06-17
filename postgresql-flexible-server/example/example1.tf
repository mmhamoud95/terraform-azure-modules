module "postgresql_flexible" {
  source  = "../"


  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = ""

  tier               = "GeneralPurpose"
  size               = "D2s_v3"
  storage_mb         = 32768
  postgresql_version = 13


  backup_retention_days        = 14
  geo_redundant_backup_enabled = true

  administrator_login    = "azureadmin"
  administrator_password = random_password.admin_password.result

  databases = {
    mydatabase = {
      collation = "en_US.UTF8"
      charset   = "UTF8"
    }
  }

  maintenance_window = {
    day_of_week  = 3
    start_hour   = 3
    start_minute = 0
  }



  tags = {
    foo = "bar"
  }
}