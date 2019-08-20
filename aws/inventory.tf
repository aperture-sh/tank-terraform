## CREATES ANSIBLE HOSTS FILE FROM TEMPLATE ##

data  "template_file" "aws" {
    template = "${file("./templates/hosts.tpl")}"
    vars = {
        tank_nodes = "${join("\n", aws_instance.tank.*.private_ip)}"
        cassandra_nodes = "${join("\n", aws_instance.cassandra.*.private_ip)}"
        number_of_seeds = "${var.number_of_cassandra_seeds}"
        vm_username = "ubuntu"
        docker_username = var.docker_username
        docker_password = var.docker_password
        cassandra_data_dir = "/opt/data"
        bastion_node = aws_instance.gateway.public_dns
        proxy_node = aws_instance.gateway.private_ip
        db_vol_device = "/dev/xvdf"
        mapbox_key = "${var.mapbox_key}"
    }
}

resource "local_file" "aws_file" {
  content  = "${data.template_file.aws.rendered}"
  filename = "./ansible/cloud-hosts"
}