job "traefik" {
  datacenters = ${az}
  region      = "${region}"
  type        = "service"

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "10m"
    auto_revert = true
  }

  group "traefik" {
    count = 4

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:${version}"
        port_map {
          http = 80
          internal = 81
          api = 8080
        }

        dns_servers = ["169.254.1.1"]

        args = [
          "--consul",
          "--consul.watch",
          "--consul.endpoint=$${attr.unique.network.ip-address}:${consul_port}",
          "--consul.prefix=${traefik_consul_prefix}",
        ]
      }

      service {
        port = "http"

        check {
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
          port     = "api"
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
