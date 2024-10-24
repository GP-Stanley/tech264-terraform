# Create the VNet with Two Subnets
provider "azurerm" {
  features {}
}

# Create a VNet
resource "azurerm_virtual_network" "tech264_georgia_vnet" {
  name                = "tech264_georgia_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "UK South"
  resource_group_name = "tech264_georgia_resource_group"
}

# Create two subnets within the VNet
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = "tech264_georgia_resource_group"
  virtual_network_name = azurerm_virtual_network.tech264_georgia_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = "tech264_georgia_resource_group"
  virtual_network_name = azurerm_virtual_network.tech264_georgia_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# App VM NSG (allow ports 22, 80, 3000)
resource "azurerm_network_security_group" "tech264_georgia_app_nsg" {
  name                = "tech264_georgia_app_nsg"
  location            = "UK South"
  resource_group_name = "tech264_georgia_resource_group"

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_3000"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# DB VM NSG (allow SSH and MongoDB, deny all else)
resource "azurerm_network_security_group" "tech264_georgia_db_nsg" {
  name                = "tech264_georgia_db_nsg"
  location            = "UK South"
  resource_group_name = "tech264_georgia_resource_group"

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_mongo"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "10.0.1.0/24" # CIDR of the public subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Network Interface for App VM
resource "azurerm_network_interface" "tech264_georgia_app_nic" {
  name                = "tech264_georgia_app_nic"
  location            = "UK South"
  resource_group_name = "tech264_georgia_resource_group"
  ip_configuration {
    name                          = "app-ip-config"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create App VM
resource "azurerm_virtual_machine" "app_instance" {
  name                  = "app-instance"
  location              = "UK South"
  resource_group_name   = "tech264_georgia_resource_group"
  network_interface_ids = [azurerm_network_interface.tech264_georgia_app_nic.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "app_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "appvm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }
}

# NSG association for App VM
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.tech264_georgia_app_nic.id
  network_security_group_id = azurerm_network_security_group.tech264_georgia_app_nsg.id
}

# Create Network Interface for DB VM
resource "azurerm_network_interface" "tech264_georgia_db_nic" {
  name                = "tech264_georgia_db_nic"
  location            = "UK South"
  resource_group_name = "tech264_georgia_resource_group"
  ip_configuration {
    name                          = "db-ip-config"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create DB VM
resource "azurerm_virtual_machine" "db_instance" {
  name                  = "db-instance"
  location              = "UK South"
  resource_group_name   = "tech264_georgia_resource_group"
  network_interface_ids = [azurerm_network_interface.tech264_georgia_db_nic.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "db_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "dbvm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }
}

# NSG association for DB VM
resource "azurerm_network_interface_security_group_association" "db_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.tech264_georgia_db_nic.id
  network_security_group_id = azurerm_network_security_group.tech264_georgia_db_nsg.id
}
