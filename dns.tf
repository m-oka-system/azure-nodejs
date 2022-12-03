################################
# Azure DNS
################################
resource "azurerm_dns_zone" "public" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "appgw" {
  name                = var.custom_domain_host_name
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.appgw.id
}
