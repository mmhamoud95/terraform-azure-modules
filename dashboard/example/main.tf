module "dashboard" {

  source = "../"

  resource_group_name = "dashboard-rg"
  location            = "westeurope"

  dashboards = [
    {
      name     = "dash1"
      tpl_file = "simple_dashboard1_json.tpl"
      variables = {
        title = "markdown1"
      }
    }
  ]

  tags = {
    tag1 = "value1"
  }
}