################################
# Virtual network
################################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-${var.env}-main-vnet"
  address_space       = ["192.168.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "business" {
  name                 = "business-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.3.0/24"]

  delegation {
    name = "dlg-Microsoft.DBforMySQL-flexibleServers"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.0.0/24"]
}

#################################
# Network security group
################################
# Gateway subnet
resource "azurerm_network_security_group" "gateway" {
  name                = "${var.prefix}-${var.env}-gateway-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "in_http_from_all" {
  name                        = "AllowAnyHTTPInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.gateway.name
}

resource "azurerm_network_security_rule" "in_https_from_all" {
  name                        = "AllowAnyHTTPSInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.gateway.name
}

resource "azurerm_subnet_network_security_group_association" "gateway" {
  subnet_id                 = azurerm_subnet.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}

# Business subnet
resource "azurerm_network_security_group" "business" {
  name                = "${var.prefix}-${var.env}-business-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "in_ssh_from_myip" {
  name                        = "AllowMyIpAddressSSHInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.business.name
}

resource "azurerm_network_security_rule" "in_nodejs_from_myip" {
  name                        = "AllowMyIpAddressNodejsInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefixes     = var.allowed_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.business.name
}

resource "azurerm_subnet_network_security_group_association" "business" {
  subnet_id                 = azurerm_subnet.business.id
  network_security_group_id = azurerm_network_security_group.business.id
}

# Data subnet
resource "azurerm_network_security_group" "data" {
  name                = "${var.prefix}-${var.env}-data-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}
