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
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
  default     = "YourP@ssword1234"
}