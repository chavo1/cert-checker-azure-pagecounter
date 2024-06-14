# Output the public IP address of the load balancer.
output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_public_ip.ip_address
  description = "The public IP address of the load balancer"
}
# Output the private IP address of the MySQL server.
output "mysql_private_ip" {
  value       = azurerm_network_interface.db.private_ip_address
  description = "The private IP address of the MySQL server"
}
# Output the public IP addresses of the web servers.
output "web_server_public_ips" {
  value       = [for k, ni in azurerm_network_interface.web : azurerm_public_ip.web_public_ip[k].ip_address]
  description = "The public IP addresses of the web servers"
}
# Output the private IP addresses of the web servers.
output "web_server_private_ips" {
  value       = [for ni in azurerm_network_interface.web : ni.private_ip_address]
  description = "The private IP addresses of the web servers"
}
# Output the details of the web server network interfaces.
output "web_server_nics" {
  value = azurerm_network_interface.web
}
# Output debug information for the public IP addresses of the web servers.
output "web_server_public_ips_debug" {
  value       = { for k, v in azurerm_public_ip.web_public_ip : k => v.ip_address }
  description = "Debug information for public IP addresses of the web servers"
}
