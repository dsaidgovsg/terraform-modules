locals {
  fluentd_server_port = 4224
  fluentd_lb_port     = 4224
}

resource "aws_ecs_service" "fluentd_docker" {
  name = "fluentd-docker"

}


resource "docker_container" "fluentd" {
  name  = "fluentd"
  image = "${var.fluentd_image}:${var.fluentd_tag}"
  # force_pull = 
  dns = ["169.254.1.1"]\

  ports {
    internal = 4224
    external = 4224
  }

  volumes {
    host_path      = "${fluentd_conf_file}"
    container_path = "/fluentd/etc/fluent.conf"
    read_only      = true
  }

  volumes {
    host_path      = "alloc/logs"
    container_path = "/fluentd/logs"
  }

  volumes {
    host_path      = "alloc/buffer"
    container_path = "/fluentd/buffer"
  }

  volumes {
    host_path      = "secrets/config"
    container_path = "/config/secrets"
    read_only      = true
  }

  volumes {
    host_path      = "alloc/additional"
    container_path = "/config/additional"
    read_only      = true
  }
}
