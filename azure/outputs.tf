output "gateway_ip" {
    value = "${azurerm_public_ip.gateway_public_ip.ip_address}"
}