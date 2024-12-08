variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "debtSolverRG"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "The deployment environment (e.g., dev or prod)."
  type        = string
  default     = "dev" # Default to development
}

#-----------------------------------------------
# Vnet variables
#-----------------------------------------------
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "appVnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "vmSubnet"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "trusted_ip_ranges" {
  description = "Trusted IP ranges for different environments."
  type        = map(string)
  default = {
    dev  = "0.0.0.0/0"      # Allow all IPs in development
    prod = "142.204.0.0/16" # Restrict access in production
  }
}


#-----------------------------------------------
# DNS configuration variables
#-----------------------------------------------
variable "dns_zone_name" {
  type    = string
  default = "debtsolver.com" # Custom domain
}

variable "dns_subdomain" {
  type    = string
  default = "be" # Subdomain
}

#-----------------------------------------------
# VM variables
#-----------------------------------------------

variable "vm_name" {
  description = "Name of the Virtual Machine"
  type        = string
  default     = "myVM"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "vm_name_kind" {
  description = "Name of the VM for Kubernetes Kind cluster"
  default     = "myKindVM"
}


/*
variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}
*/

# PostgreSQL variables
variable "postgresql_server_name" {
  default = "mypostgresqldbserver"
}

variable "postgresql_admin_username" {
  default = "adminuser"
}

variable "postgresql_admin_password" {
  description = "The password for the PostgreSQL admin user"
  default     = "YourP@ssw0rd!"
  sensitive   = true
}

variable "postgresql_database_name" {
  default = "mydatabase"
}
