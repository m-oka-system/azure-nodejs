
#################################
# Virtual machines
################################
resource "azurerm_public_ip" "vm" {
  name                = "${var.prefix}-${var.env}-appsvr-vm-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.prefix}-${var.env}-appsvr-vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.business.id
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-${var.env}-appsvr-vm"
  computer_name       = "appsvr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  priority        = "Spot"
  max_bid_price   = -1
  eviction_policy = "Deallocate"

  allow_extension_operations      = true
  disable_password_authentication = true
  encryption_at_host_enabled      = false
  patch_mode                      = "ImageDefault"
  secure_boot_enabled             = false
  vtpm_enabled                    = false
  custom_data                     = filebase64("userdata.sh")

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  boot_diagnostics {}

  os_disk {
    name                      = "${var.prefix}-${var.env}-appsvr-vm-osdisk"
    caching                   = "ReadWrite"
    storage_account_type      = "Standard_LRS"
    disk_size_gb              = 30
    write_accelerator_enabled = false
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.app.id
    ]
  }

  source_image_reference {
    offer     = "CentOS"
    publisher = "OpenLogic"
    sku       = "7_9-gen2"
    version   = "latest"
  }
}

# User Assigned Managed ID
resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.prefix}-${var.env}-appsvr-mngid"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}
