# Define the provider
provider "azurerm" {
  features {}

  # Azure details, replace with sub IP or use env
  subscription_id = "56ac1107-64d9-439a-9c99-dd90aa2f458e"
}

# Create a resource group
resource "azurerm_resource_group" "my_rg" {
  name     = var.resource_group_name
  location = var.location
}

# VNet to hold backend server
resource "azurerm_virtual_network" "my_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
}

# Subnet
resource "azurerm_subnet" "my_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = var.subnet_address_prefix
}

resource "azurerm_network_interface" "my_nic" {
  name                = "vmNIC"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "vmIPConfig"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_public_ip.id
  }
}

# Public IP of BE host
resource "azurerm_public_ip" "my_public_ip" {
  name                = "vmPublicIP"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# VM for hosting Go Backend
resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("./a1.pub") # Replace with the path to your SSH public key
  }

  network_interface_ids = [azurerm_network_interface.my_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Load and encode the external script file
  custom_data = base64encode(file("install_docker.sh"))
}

# Network Security Group (NSG) to control inbound traffic
resource "azurerm_network_security_group" "my_nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  # Allow SSH (port 22) from anywhere
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0" # Allows from any IP
    destination_address_prefix = "*"
  }

  # Allow HTTP (port 80) from anywhere
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0" # Allows from any IP
    destination_address_prefix = "*"
  }

  # Allow inbound access to PostgreSQL on port 5432 from any IP
  security_rule {
    name                       = "AllowPostgres"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "0.0.0.0/0"    # Allows access from any IP
    destination_address_prefix = "*"
  }

  # (Optional) Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG association with the Subnet
resource "azurerm_subnet_network_security_group_association" "my_nsg_association" {
  subnet_id                 = azurerm_subnet.my_subnet.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

# Create Azure ACR
resource "azurerm_container_registry" "my_acr" {
  name                     = "debtsolverdockerregistry"            # Must be globally unique
  resource_group_name      = azurerm_resource_group.my_rg.name
  location                 = azurerm_resource_group.my_rg.location
  sku                      = "Basic"                       # Options are Basic, Standard, or Premium
  admin_enabled            = true                          # Enables admin user login

  tags = {
    Environment = "Dev"
  }
}
