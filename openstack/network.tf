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
