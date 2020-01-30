resource "azurerm_network_security_group" "vm_sg" {
    name                =   var.vm_sg_name 
    location            =   var.location 
    resource_group_name =   azurerm_resource_group.vm_resource_group.name 
    
    security_rule {
        name                        = "SSH"
        priority                   = "1001"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "22"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }

    security_rule {
        name                        = "HTTP"
        priority                   = "1003"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "80"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }

    security_rule {
        name                        = "HTTPS"
        priority                   = "1004"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "443"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }
    
    security_rule {
        name                        = "GITLABPORT"
        priority                   = "1005"
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "8081"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }

    security_rule {
        name                         = "outbound"
		priority                    = "1002"
		direction                    = "Outbound"
		access                       = "Allow"
		protocol                     = "Tcp"
		source_port_range            = "*"
		destination_port_range       = "*"
		source_address_prefix        = "*"
		destination_address_prefix   = "*"
    }

    tags = {
        environment  = var.tags_environment_vm_sg
    }
}