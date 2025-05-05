output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.rfp-linux-vm.name}: ${data.azurerm_public_ip.rfp-ip-data.ip_address}"
}

output "name" {
  value = cloudflare_dns_record.rfp-linux-host-dns.name
}

output "content" {
  value     = cloudflare_dns_record.rfp-linux-host-dns.content
  sensitive = false
}

output "ttl" {
  value = cloudflare_dns_record.rfp-linux-host-dns.ttl
}

output "type" {
  value = cloudflare_dns_record.rfp-linux-host-dns.type
}
