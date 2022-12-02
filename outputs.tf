output "vm_public_ip_address" {
  value = azurerm_public_ip.vm.ip_address
}

output "mysqlfs_fqdn" {
  value = azurerm_mysql_flexible_server.mysqlfs.fqdn
}
