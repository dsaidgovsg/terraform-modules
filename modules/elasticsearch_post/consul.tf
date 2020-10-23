resource "consul_node" "es" {
  name    = var.es_consul_service
  address = var.es_endpoint
}

resource "consul_service" "es" {
  node = consul_node.es.name
  name = var.es_consul_service
  port = var.es_default_access["port"]

  check {
    check_id                          = "service:elasticsearch"
    name                              = "Elasticsearch cluster health check"
    status                            = "passing"
    http                              = "https://${var.es_endpoint}/_cluster/health"
    tls_skip_verify                   = false
    interval                          = "30s"
    timeout                           = "10s"
    deregister_critical_service_after = "600s"
  }
}
