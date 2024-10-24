
# Terraform Documentation
Source: https://developer.hashicorp.com/terraform/docs

# Task: Use Terraform to create a 2-tier deployment on Azure
* Create your own VNet with 2 subnets
  * Use the same CIDR blocks as you used when we created the 2-subnet VNet manually
* Create the app VM's NSG to allow ports 22, 80 and 3000
* Create the DB VM's NSG to allow:
  * SSH
  * Mongo DB from public-subnet CIDR block
  * Deny everything else
* Create the app-instance and db-instance in the VNet created by Terraform, and to use the NSGs created by Terraform

Helpful hints:
* Use the official documentation for Terraform
* Name things appropriately so that you know what you created with Terraform

Extra credit:
* Work out how we can get Terraform to add key to our EC2 instance
* Work out how to get user data to run on each of the VMs

<br>

# 1. Create the VNet with Two Subnets
* In your Terraform configuration (main.tf), define an Azure Virtual Network (VNet) with two subnets. 
* Use the same CIDR blocks that you used earlier when creating the VNet manually (0.0.0.0/0).

```bash
provider "azurerm" {        # azurerm stands for Azure Resource Manager
  features {}
}

# Create a VNet
resource "azurerm_virtual_network" "tech264_georgia_vnet" {
  name                = "tech264_georgia_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eu-west-1"
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
```

# 2. Create NSGs for App VM and DB VM
* Define the Network Security Groups (NSGs) to control access to your app and database instances.

## 2.1 App VM NSG (allow ports 22, 80, 3000)

## 2.2 DB VM NSG (allow SSH and MongoDB, deny all else)