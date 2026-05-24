output "resource_group_name" {
  description = "Name of the lab resource group."
  value       = azurerm_resource_group.lab.name
}

output "vnet_id" {
  description = "Resource ID of the lab VNet."
  value       = azurerm_virtual_network.lab.id
}

output "dc_private_ip" {
  description = "Private IP address of the domain controller."
  value       = local.dc_private_ip
}

output "dc_vm_id" {
  description = "Resource ID of the domain controller VM."
  value       = azurerm_windows_virtual_machine.dc.id
}

output "server_private_ip" {
  description = "Private IP address of the Windows Server domain member."
  value       = azurerm_network_interface.srv.private_ip_address
}

output "server_vm_id" {
  description = "Resource ID of the server VM."
  value       = azurerm_windows_virtual_machine.srv.id
}

output "bastion_name" {
  description = "Name of the Bastion host — use this in the Azure Portal to connect."
  value       = azurerm_bastion_host.lab.name
}

output "domain_name" {
  description = "Fully qualified domain name of the new AD forest."
  value       = var.domain_name
}
