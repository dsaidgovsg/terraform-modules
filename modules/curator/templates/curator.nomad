job "${job_name}" {
  constraint {
    attribute = "$${node.class}"
    value     = "${node_class}"
  }

  datacenters = ${az}
  region      = "${region}"
  type        = "batch"


  periodic {
    cron             = "${cron}"
    prohibit_overlap = true
    time_zone        = "${timezone}"
  }

  group "${job_name}" {
    count = 1

    # `restart` in combination with the default `reschedule` will attempt this job for ten times.
    restart {
      attempts = 5
      mode     = "fail"
    }

    task "${job_name}" {
      driver = "docker"

      config {
        image      = "${docker_image}:${docker_tag}"
        force_pull = ${force_pull}

        dns_servers = ["169.254.1.1"]

        entrypoint = ${entrypoint}
        command    = "${command}"
        args       = ${args}

        volumes = [
          "local/config.yml:${config_path}",
          "local/actions.yml:${actions_path}",
        ]

        ${additional_docker_config}
      }

      template {
        change_mode = "noop"
        data = <<EOF
${config}
EOF
        destination = "local/config.yml"
      }

      template {
        change_mode = "noop"
        data = <<EOF
${actions}
EOF
        destination = "local/actions.yml"
      }

      env {
        CONSUL_PREFIX         = "${consul_prefix}"
        ELASTICSEARCH_SERVICE = "${elasticsearch_service}"
      }

      resources {
        cpu    = 500
        memory = 512

        network {
          mbits = 5
        }
      }
    }
  }
}
