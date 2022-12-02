##########################################
# Azure Database for MySQL Flexible Server
##########################################
locals {
  mysql_flexible_server_name = "${var.prefix}-${var.env}-mysql${random_integer.num.result}"
}

resource "azurerm_mysql_flexible_server" "mysqlfs" {
  name                   = local.mysql_flexible_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.location
  administrator_login    = var.db_username
  administrator_password = var.db_password
  sku_name               = var.db_size
  version                = "8.0.21"
  zone                   = "1"

  backup_retention_days        = 7
  delegated_subnet_id          = azurerm_subnet.data.id
  private_dns_zone_id          = azurerm_private_dns_zone.mysqlfs.id
  geo_redundant_backup_enabled = false

  storage {
    auto_grow_enabled = true
    iops              = 360
    size_gb           = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysqlfs]
}

resource "azurerm_mysql_flexible_database" "mysqlfs" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysqlfs.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_private_dns_zone" "mysqlfs" {
  name                = "${local.mysql_flexible_server_name}.private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysqlfs" {
  name                  = "mysqlfsVnetZone"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysqlfs.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
