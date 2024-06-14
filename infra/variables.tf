# Define the number of virtual machines to create.
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}
# Base name for all resources.
variable "base_name" {
  description = "Base name for all resources"
  type        = string
  default     = "webapp"
}
