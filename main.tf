provider "azurerm" {
  tenant_id = "edcea3bb-b476-4bbe-8d38-7f4f90741436"
  features {}
}


resource "azurerm_resource_group" "main" {
    name     = "${var.prefix}_udacity_rg"
    location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "load_balancer-network"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                  = "${azurerm_resource_group.main.name}-public_ip-http_server"
  location              = "East US"
  resource_group_name   = azurerm_resource_group.main.name
  allocation_method     = "Static"
}

resource "azurerm_lb" "main" {
  name   = "TestLoadBalancer"
  location = "East US"
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
      name = "PublicIPAddress"
      public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = azurerm_resource_group.main.name
 loadbalancer_id     = azurerm_lb.main.id
 name                = "BackEndAddressPool"
}


resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id

}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    
  }
}

resource "azurerm_network_security_group" "main" {
  name = "${azurerm_resource_group.main.name}_secutiry-group"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "main" {
  name                        = "${azurerm_resource_group.main.name}_security-rule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  source_address_prefixes       = azurerm_subnet.internal.address_prefixes
  destination_address_prefixes  = azurerm_subnet.internal.address_prefixes
}

resource "azurerm_availability_set" "main" {
  name                = "${azurerm_resource_group.main.name}-avaliability-set"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_machine_scale_set" "main" {
  name                            = "mytestscaleset-1"
  upgrade_policy_mode             = "Manual"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location

  sku {
    name = "Standard_B1ls"
    capacity = "1"
  }
  os_profile {
    computer_name_prefix            = "udc"
    admin_username                  = var.admin_username
    admin_password                  = var.admin_password
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary = true
    }
  }

  storage_profile_image_reference {
    id = "/subscriptions/bfbe18a5-bbc4-4318-aaf3-057f52efb75b/resourceGroups/builder_resource_group/providers/Microsoft.Compute/images/HttpServer_Udacity"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

}