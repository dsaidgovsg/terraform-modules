job "fluentd" {
  constraint {
    attribute = "$${node.class}"
    operator  = "${node_class_operator}"
    value     = "${node_class}"
  }

  datacenters = ${az}
  region      = "${region}"
  type        = "service"

  priority = 100

  update {
    max_parallel = 1
    auto_revert  = true
  }

  group "fluentd" {
    count = ${fluentd_count}

    ephemeral_disk {
      migrate = true
      size    = "1024"
      sticky  = true
    }

    vault {
      policies = ["${vault_policy}"]

      change_mode = "restart"
    }

    task "fluentd" {
      driver = "docker"

      # Nomad kills jobs with SIGINT. Fluentd will try to flush
      # https://docs.fluentd.org/v0.12/articles/signals
      # Give it time to flush. This is the max on agents
      kill_timeout = "30s"

      config = {
        image      = "${fluentd_image}:${fluentd_tag}"
        force_pull = ${fluentd_force_pull}

        port_map {
          forwarder = ${fluentd_port}
        }

        volumes = [
          "${fluentd_conf_file}:/fluentd/etc/fluent.conf",
          "alloc/logs:/fluentd/logs:rw",
          "secrets/config:/config/secrets",
          "alloc/additional:/config/additional",
        ]

        dns_servers = ["169.254.1.1"]
      }

      template {
        data = <<EOH
${fluentd_conf_template}
EOH

        destination = "${fluentd_conf_file}"

        # Signal Fluentd to reload configuration: ttps://docs.fluentd.org/v1.0/articles/signals
        change_mode = "restart"
      }

      template {
        destination = "secrets/aws.env"
        env = true

        data = <<EOH
{{- with secret "${aws_path}" -}}
AWS_ACCESS_KEY_ID="{{ .Data.access_key }}"
AWS_SECRET_ACCESS_KEY="{{ .Data.secret_key }}"
{{ end }}
EOH
      }

      ${additional_blocks}

      service {
        name = "$${JOB}"
        port = "forwarder"

        check {
          port     = "forwarder"
          type     = "tcp"
          path     = "/"
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit = 3
            grace = "60s"
          }
        }
      }

      service {
        name = "$${JOB}-prometheus"
        port = "prometheus"
        tags = ["prometheus"]
      }

      resources {
        cpu    = ${fluentd_cpu}
        memory = ${fluentd_memory}

        network {
          mbits = 100

          port "forwarder" {
            static = ${fluentd_port}
          }

          port "prometheus" {
            static = ${fluentd_prometheus_port}
          }
        }
      }
    }
  }
}
