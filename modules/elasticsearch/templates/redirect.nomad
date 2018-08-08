job "${redirect_job_name}" {
  constraint {
    attribute = "$${meta.tag}"
    operator  = "="
    value     = "${meta_tag_value}"
  }

  datacenters = ${az}
  region      = "${region}"
  type        = "service"

  update {
    max_parallel     = 1
    auto_revert      = true
  }

  group "${redirect_job_name}" {
    count = 2

    task "${redirect_job_name}" {
      driver = "docker"

      config {
        image = "nginx:${redirect_nginx_version}"

        port_map {
          http = 80
        }

        volumes = [
          "alloc/nginx.conf:/etc/nginx/conf.d/default.conf:ro",
        ]

        dns_servers = ["169.254.1.1"]

        # Keep default logging -- nothing special to keep track of!
      }

      template {
        data = <<EOH
server {
    listen       80;
    server_name  localhost;

    rewrite ^ https://{{ with service "${elasticsearch_service}" }}{{ (index . 0).Address }}{{ end }}/_plugin/kibana/;
}
EOH

        destination = "alloc/nginx.conf"
        change_mode = "restart"
      }

      service {
        name = "$${JOB}"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [
          "traefik.enable=true",
          "traefik.frontend.rule=Host:${redirect_domain}",
          "traefik.frontend.entryPoints=internal",
          "traefik.frontend.headers.SSLRedirect=true",
          "traefik.frontend.headers.SSLProxyHeaders=X-Forwarded-Proto:https",
          "traefik.frontend.headers.STSSeconds=315360000",
          "traefik.frontend.headers.frameDeny=true",
          "traefik.frontend.headers.browserXSSFilter=true",
          "traefik.frontend.headers.contentTypeNosniff=true",
          "traefik.frontend.headers.referrerPolicy=strict-origin",
          "traefik.frontend.headers.contentSecurityPolicy=default-src 'none';"
        ]
      }

      resources {
        cpu    = 128
        memory = 64

        network {
          mbits = 200

          port "http" { }
        }
      }
    }
  }
}
