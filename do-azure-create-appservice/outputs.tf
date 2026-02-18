output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "service_plan_name" {
  value = azurerm_service_plan.asp.name
}

output "linux_web_app_name" {
  value = azurerm_linux_web_app.webapp.name
}

output "linux_web_app_hostname" {
  value = azurerm_linux_web_app.webapp.default_hostname
}

output "linux_web_dev_app_name" {
  value = azurerm_linux_web_app.dev_webapp.name
}