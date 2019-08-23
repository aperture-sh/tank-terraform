output "bastion_host" {
    value = "${aws_instance.gateway.public_dns}"
}

output "load_balancer_host" {
    value = "${aws_lb.tank_alb.dns_name}"
}