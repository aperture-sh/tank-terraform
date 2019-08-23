## CREATES ssh_config FOR CONNECTING TO PRIVATE MACHINES THROUGH BASTION HOST ##

data  "template_file" "ssh" {
    template = "${file("./templates/ssh_config.tpl")}"
    vars = {
        private_network = "${join(".", slice(split(".", var.private_subnet_cidr[0]), 0, 3)) }.*"
        public_network = "${join(".", slice(split(".", var.public_subnet_cidr[0]), 0, 3)) }.*"
        private_network2 = "${join(".", slice(split(".", var.private_subnet_cidr[1]), 0, 3)) }.*"
        public_network2 = "${join(".", slice(split(".", var.public_subnet_cidr[1]), 0, 3)) }.*"
        bastion_node = aws_instance.gateway.public_dns
        ssh_key = "${var.keyfile}"
        ssh_username = "ubuntu"
    }
}

resource "local_file" "ssh_file" {
  content  = "${data.template_file.ssh.rendered}"
  filename = "./ssh_config"
}