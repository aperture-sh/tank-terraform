data  "template_file" "azure" {
    template = "${file("./templates/hosts.tpl")}"
    vars = {
        tank_nodes = "${join("\n", azurerm_network_interface.tank_nic.*.private_ip_address)}"
        cassandra_nodes = "${join("\n", azurerm_network_interface.cassandra_nic.*.private_ip_address)}"
        number_of_seeds = "${var.number_of_cassandra_seeds}"
        bastion_node = azurerm_public_ip.gateway_public_ip.ip_address
        proxy_node = azurerm_network_interface.gateway_nic.private_ip_address
        vm_username = var.vm_username
        docker_username = var.docker_username
        docker_password = var.docker_password
        cassandra_data_dir = "/opt/data/db"
    }
}

resource "local_file" "azure_file" {
  content  = "${data.template_file.azure.rendered}"
  filename = "./tank-ansible/cloud-hosts"
}
