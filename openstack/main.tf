# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "${var.openstack_username}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_project}"
  auth_url    = "${var.openstack_auth_url}"
}

resource "openstack_compute_instance_v2" "gateway" {
  name            = "tank-gateway"
  image_id        = "${var.image_id}"
  flavor_name       = "${var.gateway_instance_type}"
  key_pair        = "${var.keypair}"
  security_groups = ["${openstack_networking_secgroup_v2.intern.name}", "${openstack_networking_secgroup_v2.http.name}", "${openstack_networking_secgroup_v2.ssh.name}"]

  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = 15
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = "${openstack_networking_network_v2.tank_network.id}"
  }
}


resource "openstack_compute_instance_v2" "tank" {
  name            = "tank-node-${count.index}"
  count = "${var.tank_node_count}"
  image_id        = "${var.image_id}"
  flavor_name       = "${var.tank_instance_type}"
  key_pair        = "${var.keypair}"
  security_groups = ["${openstack_networking_secgroup_v2.intern.name}"]

  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = "${var.tank_disk_size}"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = "${openstack_networking_network_v2.tank_network.id}"
  }
}


resource "openstack_compute_instance_v2" "cassandra" {
  name            = "cassandra-node-${count.index}"
  count = "${var.cassandra_node_count}"
  image_id        = "${var.image_id}"
  flavor_name       = "${var.cassandra_instance_type}"
  key_pair        = "${var.keypair}"
  security_groups = ["${openstack_networking_secgroup_v2.intern.name}"]

  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = 5
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = "${openstack_networking_network_v2.tank_network.id}"
  }
}