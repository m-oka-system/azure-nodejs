resource "azurerm_storage_account" "public" {
  name                     = "${var.prefix}${var.env}sa${random_integer.num.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"

  enable_https_traffic_only     = true
  public_network_access_enabled = true

  static_website {
    index_document = "index.html"
  }

  blob_properties {
    versioning_enabled  = false
    change_feed_enabled = false

    container_delete_retention_policy {
      days = 7
    }

    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "public" {
  name                  = "public"
  storage_account_name  = azurerm_storage_account.public.name
  container_access_type = "blob"
}
