terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# The provider responsible for understanding API interactions with Docker (in this case)
provider "docker" {}

# The container resource requires an image to be specified
resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}

# The container resource is used to create and manage a Docker container.
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"

# The container resource has a ports block that can be used to expose ports from the container to the host machine.
  ports {
    internal = 80
    external = 8000
  }
}

