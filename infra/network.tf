# Create the network interface for the database VM.
resource "azurerm_network_interface" "db" {
  name                = "${local.unique_suffix}-db-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create a public IP for the load balancer.
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "${local.unique_suffix}-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}
# Create the load balancer.
resource "azurerm_lb" "main" {
  name                = "${local.unique_suffix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}
# Create a backend address pool for the load balancer.
resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${local.unique_suffix}-BackEndAddressPool"
  loadbalancer_id = azurerm_lb.main.id
}
# Create an HTTP health probe for the load balancer.
resource "azurerm_lb_probe" "http" {
  name            = "${local.unique_suffix}-http"
  loadbalancer_id = azurerm_lb.main.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}
# Create an HTTP load balancing rule.
resource "azurerm_lb_rule" "http" {
  name                           = "${local.unique_suffix}-HTTP"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
}
