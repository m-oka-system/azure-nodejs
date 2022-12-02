################################
# Key Vault
################################
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "app" {
  name                       = "${var.prefix}-${var.env}-vault"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  access_policy              = []

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.allowed_cidr
    virtual_network_subnet_ids = [
      azurerm_subnet.gateway.id,
      azurerm_subnet.business.id,
    ]
  }
}

# Secret
resource "azurerm_key_vault_secret" "db_host" {
  name         = "MYSQL-HOST"
  value        = azurerm_mysql_flexible_server.mysqlfs.fqdn
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_port" {
  name         = "MYSQL-PORT"
  value        = var.db_port
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "MYSQL-DATABASE"
  value        = var.db_name
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "MYSQL-USERNAME"
  value        = var.db_username
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "MYSQL-PASSWORD"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.app.id
}
