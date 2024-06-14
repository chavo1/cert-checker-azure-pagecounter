# Generate a unique suffix for resource names.
resource "random_id" "unique_suffix" {
  byte_length = 4
}
# Generate a unique identifier for each virtual machine disk.
resource "random_id" "vm_disks" {
  count       = var.vm_count
  byte_length = 4
}
# Local variables for VM indices and unique suffix.
locals {
  web_vm_indices = tolist(range(var.vm_count))
  unique_suffix  = format("%s-%s", var.base_name, random_id.unique_suffix.hex)
  disk_names     = { for idx in local.web_vm_indices : idx => format("%s-os-disk-%s", local.unique_suffix, random_id.vm_disks[idx].hex) }
}
# Create a resource group for all resources.
resource "azurerm_resource_group" "main" {
  name     = "${local.unique_suffix}-rg"
  location = "West Europe"
}
# Create a virtual network.
resource "azurerm_virtual_network" "main" {
  name                = "${local.unique_suffix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
# Create a subnet within the virtual network.
resource "azurerm_subnet" "main" {
  name                 = "${local.unique_suffix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create an availability set for the VMs.
resource "azurerm_availability_set" "web" {
  name                         = "${local.unique_suffix}-availability-set"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}
# Load the cloud-init script for web VMs.
data "template_file" "cloud_init_web" {
  template = file("${path.module}/cloud-init-web.tpl")

  vars = {
    db_ip = azurerm_network_interface.db.private_ip_address
  }
}
# Create a dynamic public IP for each web VM.
resource "azurerm_public_ip" "web_public_ip" {
  for_each            = { for idx in local.web_vm_indices : idx => idx }
  name                = "${local.unique_suffix}-web-pip-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}
# Create a network interface for each web VM.
resource "azurerm_network_interface" "web" {
  for_each            = { for idx in local.web_vm_indices : idx => idx }
  name                = "${local.unique_suffix}-nic-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_public_ip[each.key].id
  }
}
# Create each web VM with the given configuration.
resource "azurerm_virtual_machine" "web" {
  for_each                      = { for idx in local.web_vm_indices : idx => idx }
  name                          = "${local.unique_suffix}-vm-${each.key}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  network_interface_ids         = [azurerm_network_interface.web[each.key].id]
  availability_set_id           = azurerm_availability_set.web.id
  vm_size                       = "Standard_B1s"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = local.disk_names[each.key]
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
    computer_name  = "${local.unique_suffix}-vm-${each.key}"
    admin_username = "azureuser"
    admin_password = "P@ssword123!"
    custom_data    = data.template_file.cloud_init_web.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  lifecycle {
    create_before_destroy = true # Ensure new VM is created before the old one is destroyed.
  }

  depends_on = [azurerm_network_interface.web]
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  for_each                = { for idx in local.web_vm_indices : idx => idx }
  network_interface_id    = azurerm_network_interface.web[each.key].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id

  depends_on = [azurerm_network_interface.web]
}
