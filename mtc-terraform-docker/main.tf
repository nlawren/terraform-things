terraform {
  required_version = ">= 1.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  count   = 2
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  count = 2
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.image_id
  ports {
    internal = 1880
    # external = 1880
  }
}

output "ip_address" {
  value       = join(":", [docker_container.nodered_container[0].network_data[0].ip_address, docker_container.nodered_container[0].ports[0].external])
  description = "The IP address and port of the first container"
}

output "ip_address2" {
  value       = join(":", [docker_container.nodered_container[1].network_data[0].ip_address, docker_container.nodered_container[1].ports[0].external])
  description = "The IP address and port of the second container"
}

output "container-name" {
  value       = docker_container.nodered_container[0].name
  description = "The name of the first container"
}

output "container-name2" {
  value       = docker_container.nodered_container[1].name
  description = "The name of the second container"
}
