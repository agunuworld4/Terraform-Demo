
provider "azurerm" {
}

variable "prefix" {
  default = "agunuworldnetwork"
}

resource "azurerm_resource_group" "main" {
  name     =  "${var.prefix}-resources"
  location = "east US 2"
}

resource "azurerm_app_service_plan" "main" {
  name                = "${var.prefix}-network"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "${var.prefix}-network"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  app_service_plan_id = "${azurerm_app_service_plan.main.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.main.fully_qualified_domain_name} Database=${azurerm_sql_database.main.name};User ID=${azurerm_sql_server.main.administrator_login};Password=${azurerm_sql_server.main.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "main" {
  name                         = "terraform-sqlserver"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  location                     = "${azurerm_resource_group.main.location}"
  version                      = "12.0"
  administrator_login          = "houssem"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_database" "main" {
  name                = "terraform-sqldatabase"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  server_name         = "${azurerm_sql_server.main.name}"

  tags = {
    environment = "production"
  }
}
