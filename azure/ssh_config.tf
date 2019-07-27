data  "template_file" "ssh" {
    template = "${file("./templates/ssh_config.tpl")}"
    vars = {
        private_network = "${join(".", slice(split(".", var.subnet_cidr), 0, 3)) }.*"
        public_network = ""
        bastion_node = azurerm_public_ip.gateway_public_ip.ip_address
        ssh_key = "${var.keyfile}"
        ssh_username = "${var.vm_username}"
    }
}

resource "local_file" "ssh_file" {
  content  = "${data.template_file.ssh.rendered}"
  filename = "./ssh_config"
}