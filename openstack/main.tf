# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "${var.openstack_username}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_project}"
  auth_url    = "${var.openstack_auth_url}"
}

resource "openstack_networking_floatingip_v2" "gateway_ip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "gateway_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.gateway_ip.address}"
  instance_id = "${openstack_compute_instance_v2.gateway.id}"
  fixed_ip = "${openstack_compute_instance_v2.gateway.network.0.fixed_ip_v4}"
}

resource "openstack_blockstorage_volume_v2" "db_vol" {
  name = "db-vol-${count.index}"
  count = "${var.cassandra_node_count}"
  size = "${var.cassandra_disk_size}"
}

resource "openstack_compute_volume_attach_v2" "db_vol_attached" {
  count = "${var.cassandra_node_count}"
  instance_id = "${element(openstack_compute_instance_v2.cassandra.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.db_vol.*.id, count.index)}"
}

resource "openstack_compute_instance_v2" "gateway" {
  name            = "tank-gateway"
  image_id        = "${var.image_id}"
  flavor_name       = "${var.gateway_instance_type}"
  key_pair        = "${var.keypair}"
  security_groups = ["default", "tank", "any-intern"]

  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = 15
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "fzouhar-intern"
  }
}


resource "openstack_compute_instance_v2" "tank" {
  name            = "tank-node-${count.index}"
  count = "${var.tank_node_count}"
  image_id        = "${var.image_id}"
  flavor_name       = "${var.tank_instance_type}"
  key_pair        = "${var.keypair}"
  security_groups = ["any-intern"]

  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = "${var.tank_disk_size}"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "fzouhar-intern"
  }
}


resource "openstack_compute_instance_v2" "cassandra" {
  name            = "cassandra-node-${count.index}"
  count = "${var.cassandra_node_count}"
  image_id        = "${var.image_id}"
  flavor_name       = "${var.cassandra_instance_type}"
  key_pair        = "${var.keypair}"
  security_groups = ["any-intern"]

  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = 5
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "fzouhar-intern"
  }
}