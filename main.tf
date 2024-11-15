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

# Subnet of the VM
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
  domain_name_label   = "caa900debtsolverapp" # Set your desired DNS label here
}

/*
# DNS Zone for the custom domain
resource "azurerm_dns_zone" "my_dns_zone" {
  name                = var.dns_zone_name # Use custom domain variable
  resource_group_name = azurerm_resource_group.my_rg.name
}

# DNS A Record pointing to the Public IP
resource "azurerm_dns_a_record" "my_dns_a_record" {
  name                = var.dns_subdomain # Use subdomain variable
  zone_name           = azurerm_dns_zone.my_dns_zone.name
  resource_group_name = azurerm_resource_group.my_rg.name
  ttl                 = 300
  records             = [azurerm_public_ip.my_public_ip.ip_address] # Associate with the public IP
}
*/

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

# Network Security Group (NSG) to control traffic
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
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  # Allow HTTP (port 80) from anywhere
  security_rule {
    name                       = "AllowHTTP80"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
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
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  # Allow HTTP (port 8080) from anywhere
  security_rule {
    name                       = "AllowHTTP8080"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp" # Change to Tcp from "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  # (Basic) Deny all other inbound traffic
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

/*
#-----------------------------------------------------------------------------------
# VM for Kubernetes Kind Cluster
resource "azurerm_linux_virtual_machine" "my_vm_kind" {
  name                = var.vm_name_kind # New variable for this VM's name
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("./a1.pub") # Replace with the path to your SSH public key
  }

  network_interface_ids = [azurerm_network_interface.my_nic_kind.id] # New NIC for this VM

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

  # Custom script to install Docker and Kind
  custom_data = base64encode(file("install_docker_and_kind.sh"))
}

# Additional Network Interface for Second VM
resource "azurerm_network_interface" "my_nic_kind" {
  name                = "vmNICKind"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "vmIPConfigKind"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_public_ip_kind.id # New public IP
  }
}

# Public IP for the second VM
resource "azurerm_public_ip" "my_public_ip_kind" {
  name                = "vmPublicIPKind"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

/*
# Create PostgreSQL Single Server with Azure Database
resource "azurerm_postgresql_server" "my_postgresql_server" {
  name                = var.postgresql_server_name
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  administrator_login          = var.postgresql_admin_username
  administrator_login_password = var.postgresql_admin_password

  sku_name   = "B_Gen5_1" # Basic SKU
  storage_mb = 5120       # Minimum storage for basic SKU

  version                 = "11" # PostgreSQL version 11 (or change to 10, 12, etc.)
  ssl_enforcement_enabled = true

  geo_redundant_backup_enabled = false
  backup_retention_days        = 7 # For development workloads, this is often enough

  tags = {
    Environment = "Development"
    Workload    = "Development"
  }
}

# Create the PostgreSQL database
resource "azurerm_postgresql_database" "my_database" {
  name                = var.postgresql_database_name
  resource_group_name = azurerm_resource_group.my_rg.name
  server_name         = azurerm_postgresql_server.my_postgresql_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# PostgreSQL firewall rule to allow VM's IP address
resource "azurerm_postgresql_firewall_rule" "allow_vm_ip" {
  name                = "AllowVMAccess"
  resource_group_name = azurerm_resource_group.my_rg.name
  server_name         = azurerm_postgresql_server.my_postgresql_server.name

  start_ip_address = azurerm_public_ip.my_public_ip.ip_address
  end_ip_address   = azurerm_public_ip.my_public_ip.ip_address
}
*/