data  "template_file" "ssh" {
    template = "${file("./templates/ssh_config.tpl")}"
    vars = {
        network = "${join(".", slice(split(".", var.subnet_cidr), 0, 3)) }.*"
        bastion_node = azurerm_public_ip.gateway_public_ip.ip_address
        ssh_key = "${var.keyfile}"
        ssh_username = "${var.vm_username}"
    }
}

resource "local_file" "ssh_file" {
  content  = "${data.template_file.ssh.rendered}"
  filename = "./ssh_config"
}