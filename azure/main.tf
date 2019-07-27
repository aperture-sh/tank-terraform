provider "azurerm" {
  
}

# Create a resource group
resource "azurerm_resource_group" "tank" {
  name     = "tank"
  location = "${var.region}"
}


resource "azurerm_virtual_network" "vnet" {
  name                = "tank-network"
  resource_group_name = "${azurerm_resource_group.tank.name}"
  location            = "${azurerm_resource_group.tank.location}"
  address_space       = ["${var.cidr}"]
}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = "tank-subnet"
    resource_group_name  = "${azurerm_resource_group.tank.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix       = "${var.subnet_cidr}"
}

# Create public IP
resource "azurerm_public_ip" "gateway_public_ip" {
    name                         = "gateway-public-ip"
    location                     = "${azurerm_resource_group.tank.location}"
    resource_group_name          = "${azurerm_resource_group.tank.name}"
    allocation_method = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "ssh_sg" {
    name                = "ssh-sg"
    location            = "${azurerm_resource_group.tank.location}"
    resource_group_name = "${azurerm_resource_group.tank.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_security_group" "gateway_sg" {
    name                = "gateway-sg"
    location            = "${azurerm_resource_group.tank.location}"
    resource_group_name = "${azurerm_resource_group.tank.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "gateway_nic" {
    name                      = "gateway-nic"
    location                  = "${azurerm_resource_group.tank.location}"
    resource_group_name       = "${azurerm_resource_group.tank.name}"
    network_security_group_id = "${azurerm_network_security_group.gateway_sg.id}"

    ip_configuration {
        name                          = "gateway-nic"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.gateway_public_ip.id}"
    }
}

resource "azurerm_network_interface" "tank_nic" {
    name                      = "tank-nic-${count.index}"
    count = "${var.tank_node_count}"
    location                  = "${azurerm_resource_group.tank.location}"
    resource_group_name       = "${azurerm_resource_group.tank.name}"
    network_security_group_id = "${azurerm_network_security_group.ssh_sg.id}"

    ip_configuration {
        name                          = "tank-nic"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface" "cassandra_nic" {
    name                      = "cassandra-nic-${count.index}"
    count = "${var.cassandra_node_count}"
    location                  = "${azurerm_resource_group.tank.location}"
    resource_group_name       = "${azurerm_resource_group.tank.name}"
    network_security_group_id = "${azurerm_network_security_group.ssh_sg.id}"

    ip_configuration {
        name                          = "cassandra-nic"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
    }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "gateway_vm" {
    name                  = "gateway-vm"
    location              = "${azurerm_resource_group.tank.location}"
    resource_group_name   = "${azurerm_resource_group.tank.name}"
    network_interface_ids = ["${azurerm_network_interface.gateway_nic.id}"]
    vm_size               = "${var.gateway_instance_type}"

    storage_os_disk {
        name              = "gateway-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "gateway-vm"
        admin_username = "${var.vm_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
          key_data = file("~/.ssh/id_rsa.pub")
          path = "/home/${var.vm_username}/.ssh/authorized_keys"
        }
    }
    # custom_data = "${file("files/attach_ebs.sh")}"

}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "tank_vm" {
    name                  = "tank-vm-${count.index}"
    count = "${var.tank_node_count}"
    location              = "${azurerm_resource_group.tank.location}"
    resource_group_name   = "${azurerm_resource_group.tank.name}"
    network_interface_ids = ["${element(azurerm_network_interface.tank_nic.*.id, count.index)}"]
    vm_size               = "${var.tank_instance_type}"

    storage_os_disk {
        name              = "tank-disk-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "tank-vm-${count.index}"
        admin_username = "${var.vm_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
          key_data = file("~/.ssh/id_rsa.pub")
          path = "/home/${var.vm_username}/.ssh/authorized_keys"
        }
    }

    # custom_data = "${file("files/attach_ebs.sh")}"

}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "cassandra_vm" {
    name                  = "cassandra-vm-${count.index}"
    count = "${var.cassandra_node_count}"
    location              = "${azurerm_resource_group.tank.location}"
    resource_group_name   = "${azurerm_resource_group.tank.name}"
    network_interface_ids = ["${element(azurerm_network_interface.cassandra_nic.*.id, count.index)}"]
    vm_size               = "${var.cassandra_instance_type}"

    storage_os_disk {
        name              = "cassandra-disk-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "cassandra-vm-${count.index}"
        admin_username = "${var.vm_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
          key_data = file("~/.ssh/id_rsa.pub")
          path = "/home/${var.vm_username}/.ssh/authorized_keys"
        }
    }

    # custom_data = "${file("files/attach_ebs.sh")}"

}
