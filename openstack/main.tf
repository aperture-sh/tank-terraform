# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "${var.openstack_username}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_project}"
  auth_url    = "${var.openstack_auth_url}"
}

data "openstack_networking_network_v2" "public_network" {
  # name = "public_network"
  external = true
  # network_id = "${var.external_network_id}"
}

resource "openstack_networking_network_v2" "tank_network" {
  name           = "tank_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tank_subnet" {
  name       = "tank_subnet"
  network_id = "${openstack_networking_network_v2.tank_network.id}"
  cidr       = "${var.subnet_cidr}"
  ip_version = 4
  enable_dhcp = true
  allocation_pool {
    start = "192.168.0.2"
    end = "192.168.0.200"
  }
  # gateway_ip = 
}

resource "openstack_networking_secgroup_v2" "intern" {
  name        = "tank_intern"
  description = "allow subnet internal traffic"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_all" {
  direction = "ingress"
  ethertype         = "IPv4"
  # protocol          = "*"
  # port_range_min    = 1
  # port_range_max    = 65535
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${openstack_networking_secgroup_v2.intern.id}"
}

resource "openstack_networking_secgroup_v2" "http" {
  name        = "tank_http"
  description = "allowing http traffic"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_http" {
  direction = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.http.id}"
}

resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "tank_ssh"
  description = "allowing http traffic"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.ssh.id}"
}

resource "openstack_networking_router_v2" "tank_router" {
  name                = "tank_router"
  admin_state_up      = true
  external_network_id = "${data.openstack_networking_network_v2.public_network.id}"
}

resource "openstack_networking_router_interface_v2" "tank_router_interface" {
  router_id = "${openstack_networking_router_v2.tank_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.tank_subnet.id}"
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