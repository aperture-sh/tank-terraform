output "ips" {
    value = "${openstack_networking_floatingip_v2.gateway_ip.address}"
}