provider "azurerm" {
  features {}
  use_oidc = true
}

provider "azuread" {
}
##

resource "azurerm_resource_group" "rg" {
  name     = "RG-ADFS16LAB"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "VN-ADFS16Lab"
  address_space       = ["10.0.0.0/22"] # 1024 IPs
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "SN-ADFS16Lab"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/23"] # ~512 IPs
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/27"] # ~32 IPs
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "BastionPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "BastionHost"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "BastionIPConfig"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}

locals {
  vm_names = ["VM-DC16", "VM-ADFS16", "VM-AADC16", "VM-Client"]
}

resource "azurerm_windows_virtual_machine" "vms" {
  for_each            = toset(local.vm_names)
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "labadmin"
  admin_password      = "l@bpassw0rd!"
  network_interface_ids = [
    azurerm_network_interface.vm_nics[each.key].id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "vm_nics" {
  for_each            = toset(local.vm_names)
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
