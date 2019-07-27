data  "template_file" "openstack" {
    template = "${file("./templates/hosts.tpl")}"
    vars = {
        tank_nodes = "${join("\n", openstack_compute_instance_v2.tank.*.access_ip_v4)}"
        cassandra_nodes = "${join("\n", openstack_compute_instance_v2.cassandra.*.access_ip_v4)}"
        number_of_seeds = "${var.number_of_cassandra_seeds}"
        vm_username = "ubuntu"
        proxy_node = openstack_compute_instance_v2.gateway.access_ip_v4
        docker_username = var.docker_username
        docker_password = var.docker_password
        cassandra_data_dir = "/opt/data/db"
        bastion_node = openstack_networking_floatingip_v2.gateway_ip.address
    }
}

resource "local_file" "openstack_file" {
  content  = "${data.template_file.openstack.rendered}"
  filename = "./tank-ansible/openstack-hosts"
}