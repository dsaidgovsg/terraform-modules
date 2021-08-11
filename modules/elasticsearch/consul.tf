resource "consul_node" "es" {
  name    = var.es_consul_service
  address = local.endpoint

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}

resource "consul_service" "es" {
  node = consul_node.es.name
  name = var.es_consul_service
  port = var.es_default_access["port"]
  tags = ["elasticsearch"]

  check {
    check_id                          = "service:elasticsearch"
    name                              = "Elasticsearch cluster health check"
    status                            = "passing"
    http                              = "${local.endpoint}/_cluster/health"
    method                            = "GET"
    interval                          = "30s"
    timeout                           = "10s"
    deregister_critical_service_after = "600s"
  }
}
