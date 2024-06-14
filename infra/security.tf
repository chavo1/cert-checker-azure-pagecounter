# Create a network security group for the web VMs.
resource "azurerm_network_security_group" "web_nsg" {
  name                = "${local.unique_suffix}-web-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "${local.unique_suffix}-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${local.unique_suffix}-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
# Associate the network security group with each web VM's network interface.
resource "azurerm_network_interface_security_group_association" "web" {
  for_each                  = { for idx in local.web_vm_indices : idx => idx }
  network_interface_id      = azurerm_network_interface.web[each.key].id
  network_security_group_id = azurerm_network_security_group.web_nsg.id

  depends_on = [azurerm_network_interface.web]
}
