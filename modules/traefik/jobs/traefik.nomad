job "traefik" {
  constraint {
    attribute = "$${node.class}"
    value     = "${node_class}"
  }

  datacenters = ${az}
  region      = "${region}"
  type        = "service"
  priority    = ${traefik_priority}

  update {
    max_parallel = 1
    auto_revert = true
  }

  group "traefik" {
    count = "${traefik_count}"

    task "traefik" {
      driver = "docker"

      config = {
        image = "traefik:${version}"

        port_map {
          http     = 80
          internal = 81
          api      = 8080
        }

        dns_servers = ["169.254.1.1"]

        args = [
          "--consul",
          "--consul.watch",
          "--consul.endpoint=169.254.1.1:${consul_port}",
          "--consul.prefix=${traefik_consul_prefix}",
        ]

        ${additional_docker_config}
      }

      service {
        name = "$${JOB}"
        port = "http"

        check {
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
          port     = "api"

          check_restart {
            limit = 3
            grace = "60s"
          }
        }
      }

      resources {
        cpu    = 500
        memory = 512

        network {
          mbits = 5

          port "http" {
            static = 80
          }

          port "internal" {
            static = 81
          }

          port "api" {
            static = 8080
          }
        }
      }
    }
  }
}
