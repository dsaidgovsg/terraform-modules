job "${job_name}" {
  constraint {
    attribute = "$${node.class}"
    value     = "${node_class}"
  }

  datacenters = ${az}
  region      = "${region}"
  type        = "service"

  update {
    max_parallel     = 1
    auto_revert      = true
  }

  vault {
    env         = false
    policies    = ${policies}
    change_mode = "restart"
  }

  group "${job_name}" {
    count = ${count}

    task "${job_name}" {
      driver = "docker"

      config {
        image      = "${grafana_image}:${grafana_tag}"
        force_pull = ${grafana_force_pull}

        port_map {
          default = ${grafana_port}
        }

        volumes = [
          "secrets/grafana.ini:/etc/grafana/grafana.ini:ro",
          "secrets/provisioning:/etc/grafana/provisioning:ro",
          "alloc/dashboards:/etc/grafana/dashboards:ro",
        ]

        dns_servers = ["169.254.1.1"]

        ${additional_driver_config}
      }

      # Grafana Configuration ini
      template {
        data = <<EOH
${grafana_conf_template}
EOH
        destination = "secrets/grafana.ini"
      }

      # Cloudwatch Data Source
      template {
        data = <<EOH
${cloudwatch_datasource}
EOH
        destination = "secrets/provisioning/datasources/cloudwatch.yaml"
      }

      template {
        data = <<EOH
${prometheus_datasource}
EOH
        destination = "secrets/provisioning/datasources/prometheus.yaml"
      }

      template {
        data = <<EOH
${grafana_dashboard_aws_billing}
EOH

        destination = "alloc/dashboards/aws_billing.json"
      }

      template {
        data = <<EOH
${grafana_dashboard_aws_cloudwatch}
EOH

        destination = "alloc/dashboards/aws_cloudwatch.json"
      }

      template {
        data = <<EOH
${grafana_dashboards}
EOH

        destination = "secrets/provisioning/dashboards/file.yml"
      }

      ${additional_task_config}

      service {
        name = "$${JOB}"
        port = "default"

        check {
          port     = "default"
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit = 3
            grace = "60s"
          }
        }

        # Refer to https://docs.traefik.io/configuration/backends/consulcatalog/ for documentation
        # Be especially careful when setting the Content Security Policy.
        # See https://content-security-policy.com/
        tags = [
          "traefik.enable=true",
          "traefik.frontend.rule=Host:${grafana_fqdns}",
          "traefik.frontend.entryPoints=${grafana_entrypoints}",
          "traefik.frontend.headers.SSLRedirect=true",
          "traefik.frontend.headers.SSLProxyHeaders=X-Forwarded-Proto:https",
          "traefik.frontend.headers.STSSeconds=315360000",
          "traefik.frontend.headers.frameDeny=true",
          "traefik.frontend.headers.browserXSSFilter=true",
          "traefik.frontend.headers.contentTypeNosniff=true",
          "traefik.frontend.headers.referrerPolicy=strict-origin",
          "traefik.frontend.headers.contentSecurityPolicy=default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';",
        ]
      }

      resources {
        cpu    = 1000
        memory = 1024

        network {
          mbits = 100

          port "default" {}
        }
      }
    }
  }
}
