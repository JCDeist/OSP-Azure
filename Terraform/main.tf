resource "azurerm_resource_group" "{var.projectname}rg" {
  name     = "{var.projectname}-rg"
  location = "var.region"
}

resource "azurerm_virtual_network" "{var.projectname}vnet" {
  name                = "{var.projectname}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.{var.projectname}.location
  resource_group_name = azurerm_resource_group.{var.projectname}.name
}

resource "azurerm_subnet" "{var.projectname}subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.{var.projectname}.name
  virtual_network_name = azurerm_virtual_network.{var.projectname}.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "{var.projectname}networkinterface" {
  name                = "{var.projectname}-nic"
  location            = azurerm_resource_group.{var.projectname}.location
  resource_group_name = azurerm_resource_group.{var.projectname}.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.{var.projectname}.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "{var.projectname}" {
  name                = "{var.projectname}-machine"
  resource_group_name = azurerm_resource_group.{var.projectname}.name
  location            = azurerm_resource_group.{var.projectname}.location
  size                = "{var.vmsize}"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.{var.projectname}.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}