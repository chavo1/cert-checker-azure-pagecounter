output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_public_ip.ip_address
  description = "The public IP address of the load balancer"
}

output "mysql_private_ip" {
  value       = azurerm_network_interface.db.private_ip_address
  description = "The private IP address of the MySQL server"
}

output "web_server_public_ips" {
  value       = [for public_ip in azurerm_public_ip.web_public_ip : public_ip.ip_address]
  description = "The public IP addresses of the web servers"
}

# New output block for web server private IPs
output "web_server_private_ips" {
  value       = [for ni in azurerm_network_interface.web : ni.private_ip_address]
  description = "The private IP addresses of the web servers"
}