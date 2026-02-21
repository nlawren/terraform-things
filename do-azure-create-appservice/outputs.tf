output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "service_plan_names" {
  description = "The name of the App Service Plans"
  value = {
    for env, plan in azurerm_service_plan.asp :
    env => plan.name
  }
}

output "webapp_names" {
  description = "Names of the created Web Apps"
  value = {
    for env, app in azurerm_linux_web_app.webapp :
    env => app.name
  }
}

output "webapp_default_hostnames" {
  description = "Default hostnames of the created Web Apps"
  value = {
    for env, app in azurerm_linux_web_app.webapp :
    env => app.default_hostname
  }
}

output "webapp_urls" {
  description = "Full HTTPS URLs of the created Web Apps"
  value = {
    for env, app in azurerm_linux_web_app.webapp :
    env => "https://${app.default_hostname}"
  }
}