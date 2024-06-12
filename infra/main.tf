

resource "azurerm_availability_set" "web" {
  name                         = "web-availability-set"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}


data "template_file" "cloud_init_web" {
  template = file("${path.module}/cloud-init-web.tpl")

  vars = {
    db_ip = azurerm_network_interface.db.private_ip_address
  }
}

resource "azurerm_virtual_machine" "web" {
  count                 = 2
  name                  = "web-vm-${count.index}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  availability_set_id   = azurerm_availability_set.web.id
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "web-os-disk-${count.index}"
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
    computer_name  = "web-vm-${count.index}"
    admin_username = "azureuser"
    admin_password = "P@ssword123!"
    custom_data    = data.template_file.cloud_init_web.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}