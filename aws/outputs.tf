output "gateway_ip" {
    value = "${aws_instance.gateway.public_dns}"
}