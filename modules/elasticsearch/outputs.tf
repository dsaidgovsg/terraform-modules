output "arn" {
  description = "ARN of the created Elasticsearch domain"
  value       = "${aws_elasticsearch_domain.es.arn}"
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = "${aws_elasticsearch_domain.es.domain_id}"
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = "${local.endpoint}"
}

output "port" {
  description = "Elasticsearch service port"
  value       = "${var.es_default_access["port"]}"
}

output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = "https://${local.endpoint}/"
}

output "kibana_url" {
  description = "Kibana URL"
  value       = "https://${local.endpoint}/_plugin/kibana/"
}
