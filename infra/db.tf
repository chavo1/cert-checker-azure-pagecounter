resource "azurerm_virtual_machine" "db" {
  name                  = "db-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.db.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "db-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "db-vm"
    admin_username = "azureuser"
    admin_password = "P@ssword123!"
    custom_data    = file("cloud-init-db.yml")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
