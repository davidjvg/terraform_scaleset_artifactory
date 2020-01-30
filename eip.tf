# creacion del grupo de recursos

resource "azurerm_resource_group" "vm_resource_group" {
    name     =   var.vm_resource_group_name
    location =   var.location

    tags = {
        environment =   var.tags_environment_resource_group
    }
}

 # red virtual
resource "azurerm_virtual_network" "network" {
    name                =   var.network_name
    address_space       =   var.network_address_space 
    location            =   var.location
    resource_group_name =   azurerm_resource_group.vm_resource_group.name

    tags = {
        environment =   var.tags_environment_network
    }
}

    # subnet dentro de la red virtual

resource "azurerm_subnet" "subnet" {
    name                 =   var.subnet_name
    resource_group_name  =   azurerm_resource_group.vm_resource_group.name
    virtual_network_name =   azurerm_virtual_network.network.name
    address_prefix       =   var.subnet_address_prefix
}


 # Creacion de ip publica

resource "azurerm_public_ip" "publicip" {
    name                         =   var.publicip_name
    location                     =   var.location
    resource_group_name          =   azurerm_resource_group.vm_resource_group.name
    allocation_method            =   var.publicip_allocation_method

    tags = {
        environment =   var.tags_environment_publicip
    }
}



# Creación de una tarjeta de interfaz de red virtual

resource "azurerm_network_interface" "nic" {
    name                =   var.nic_name
    location            =   var.location
    resource_group_name =   azurerm_resource_group.vm_resource_group.name
    network_security_group_id =   azurerm_network_security_group.vm_sg.id

    ip_configuration {
        name                          =   var.nic_ip_configuration_name
        subnet_id                     =   azurerm_subnet.subnet.id
        private_ip_address_allocation =   var.nic_ip_configuration_private_ip_address_allocation
        public_ip_address_id          =   azurerm_public_ip.publicip.id
    }

    tags = {
        environment =   var.tags_environment_nic
    }
}
