provider "azurerm" {
subscription_id = ""
client_id = ""
client_secret = ""
tenant_id = ""
features {}

}




resource "azurerm_resource_group" "ataz300rg" {
  name     = "ataz300rg"
  location = "Australia SouthEast"
}

resource "azurerm_virtual_network" "ataz300rg" {
  name                = "at400vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ataz300rg.location
  resource_group_name = azurerm_resource_group.ataz300rg.name
}

resource "azurerm_subnet" "ataz300rg" {
  name                 = "atsub300-na"
  resource_group_name  = azurerm_resource_group.ataz300rg.name
  virtual_network_name = azurerm_virtual_network.ataz300rg.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "ataz300rg" {
  count               =  2
  name                = "ataz300rg-nic${count.index}"
  location            = azurerm_resource_group.ataz300rg.location
  resource_group_name = azurerm_resource_group.ataz300rg.name

  ip_configuration {
    name                          = "atsub300-na"
    subnet_id                     = azurerm_subnet.ataz300rg.id
    private_ip_address_allocation = "Dynamic"
   # public_ip_address_id          = azurerm_public_ip.pip.id${count.index}

    }

}

#resource "azurerm_public_ip" "pip" {
## name                = "atlabs-pip${count.index}"
  #location            = "Australia East"
 # resource_group_name = azurerm_resource_group.ataz300rg.name
  #allocation_method   = "Dynamic"
  #domain_name_label   = "tflabs1devops"
# }



resource "azurerm_windows_virtual_machine" "atv" {
  count               =  2
  name                = "atv-machine${count.index}"
  resource_group_name = azurerm_resource_group.ataz300rg.name
  location            = azurerm_resource_group.ataz300rg.location
  size                = "Standard_F2"
  admin_username      = "rsatadmin"
  admin_password      = "xxxxxxxxx"
  network_interface_ids = ["${element(azurerm_network_interface.ataz300rg.*.id, count.index)}"]
#  network_interface_ids = [
 #   azurerm_network_interface.ataz300rg.id,
  #]

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