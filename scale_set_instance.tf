resource "azurerm_lb" "artifactorylb" {
 name                = var.load_balancer_name
 location            = var.location
 resource_group_name = azurerm_resource_group.vm_resource_group.name

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.publicip.id
 }

 tags = {
     environment =   var.tags_environment_publicip
 }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = azurerm_resource_group.vm_resource_group.name
 loadbalancer_id     = azurerm_lb.artifactorylb.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "artifactory_probe" {
 resource_group_name = azurerm_resource_group.vm_resource_group.name
 loadbalancer_id     = azurerm_lb.artifactorylb.id
 name                = "ssh-running-probe"
 port                = var.application_port
}


resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = azurerm_resource_group.vm_resource_group.name
   loadbalancer_id                = azurerm_lb.artifactorylb.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.artifactory_probe.id
}

##SCALE SET

resource "azurerm_virtual_machine_scale_set" "artifactory" {
 name                = var.scale_set_name
 location            = var.location
 resource_group_name = azurerm_resource_group.vm_resource_group.name
 upgrade_policy_mode = "Automatic"

  sku {
   name     = var.vm_size
   #Standard_B2ms
   tier     = var.scale_type
   capacity = var.scale_capacity
  }

  storage_profile_image_reference {
   publisher =   var.storage_image_reference_publisher
   offer     =   var.storage_image_reference_offer
   sku       =   var.storage_image_reference_sku
   version   =   var.storage_image_reference_version
  }

  storage_profile_os_disk {
   name              =   ""
   caching           =   var.storage_os_disk_caching
   create_option     =   var.storage_os_disk_create_option
   managed_disk_type =   var.storage_os_disk_managed_disk_type
  }

  os_profile {
     computer_name_prefix  =   var.env_name
     admin_username =   var.admin_username
  }

  os_profile_linux_config {
     disable_password_authentication =   var.os_profile_linux_config_disable_password_authentication
     ssh_keys {
         path      = "/home/${var.admin_username}/.ssh/authorized_keys"
         key_data  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDh+/CsYSSsKSmJlWWiyryDUy21icOCwPV+lHm0qCZ4dt7xxQL6k0yZBZZtVjjlwHVD4rfOr8sotgtYU3nUniiH7AL2fwX14TULfkoW1mGZfjb//qAblleITG9o1bz99gi42LavuvvnuqMw2Fx8VI+Xo68pH4GRcVkWeuC48aikVV8RZOBmAESaimfKTqg/+ox61Vytu/dvba15v6w18ims8Dx22jmcRCmhmTrskTShHwvZAJciyIu+PVcN2MTD2W1lTMTbVb3UJGgS207X7F1lhx9SEY7u8Y51iX7bs+HywWOd0dPSWZkFgNaZqqQ/mILvpsMB8y8HxHsB+ysvsm7J ${var.admin_username}"
     }
  }


  network_profile {
    name    = "terraformnetworkprofile"
    network_security_group_id =   azurerm_network_security_group.vm_sg.id
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary = true
    }


#NIC publica para VMs
    ip_configuration {
      name                                   = "IPConfiguration_Public"
      subnet_id                              = azurerm_subnet.subnet.id
      primary = false

      public_ip_address_configuration {
          name = var.publicip_name_vm
          idle_timeout = 4
          domain_name_label = var.domain_name
    }
    }


  }

  extension {

  #  location                = var.location
    name                    = "test"
      #  virtual_machine_name = azurerm_virtual_machine.vm.name
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.scfile))}"
    }
    PROT

    }




    }
