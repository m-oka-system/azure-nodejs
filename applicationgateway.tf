################################
# Application Gateway
################################
locals {
  application_gateway_name       = "${var.prefix}-${var.env}-appgw"
  frontend_http_port_name        = "${var.prefix}-${var.env}-appgw-fe-http"
  frontend_ip_configuration_name = "${var.prefix}-${var.env}-appgw-feip"
  backend_address_pool_name      = "${var.prefix}-${var.env}-appgw-backend"
  backend_http_settings_name     = "${var.prefix}-${var.env}-appgw-target"
  http_listener_name             = "${var.prefix}-${var.env}-appgw-http-listener"
  http_request_routing_rule_name = "${var.prefix}-${var.env}-appgw-http-rule"
}

resource "azurerm_public_ip" "appgw" {
  name                = "${var.prefix}-${var.env}-appgw-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "appgw" {
  name                = local.application_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = local.frontend_http_port_name
    port = 80
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    protocol              = "Http"
    port                  = 3000
    request_timeout       = 20
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_http_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw" {
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = tolist(azurerm_application_gateway.appgw.backend_address_pool).0.id
  network_interface_id    = azurerm_network_interface.vm.id
}
