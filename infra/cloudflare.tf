variable "domain" {}
variable "api_key" {}
variable "email" {}
variable "name" {}
variable "zone_id" {}


module "cloudflare" {
  source = "./cloudflare"

  domain       = var.domain
  api_key      = var.api_key
  email        = var.email
  name         = var.name
  zone_id      = var.zone_id
  lb_public_ip = azurerm_public_ip.lb_public_ip.ip_address

}

output "cloudflare_domain_http_url" {
  value       = "http://${var.name}.${var.domain}"
  description = "The HTTP URL for the created Cloudflare domain"
}