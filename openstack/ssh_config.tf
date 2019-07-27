data  "template_file" "ssh" {
    template = "${file("./templates/ssh_config.tpl")}"
    vars = {
        network = "${join(".", slice(split(".", var.subnet_cidr), 0, 3)) }.*"
        bastion_node = openstack_networking_floatingip_v2.gateway_ip.address
        ssh_key = "${var.keyfile}"
        ssh_username = "ubuntu"
    }
}

resource "local_file" "ssh_file" {
  content  = "${data.template_file.ssh.rendered}"
  filename = "./ssh_config"
}