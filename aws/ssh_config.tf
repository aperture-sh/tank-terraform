data  "template_file" "ssh" {
    template = "${file("./templates/ssh_config.tpl")}"
    vars = {
        network = "${join(".", slice(split(".", var.private_subnet_cidr), 0, 3)) }.*"
        bastion_node = aws_instance.gateway.public_dns
        ssh_key = "${var.keyfile}"
        ssh_username = "ubuntu"
    }
}

resource "local_file" "ssh_file" {
  content  = "${data.template_file.ssh.rendered}"
  filename = "./ssh_config"
}