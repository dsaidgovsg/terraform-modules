output "arn" {
  description = "ARN of the created Elasticsearch domain"
  value       = aws_elasticsearch_domain.es.arn
}

output "domain_name" {
  description = "Elasticsearch domain name"
  value       = aws_elasticsearch_domain.es.domain_name
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = aws_elasticsearch_domain.es.domain_id
}

output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = "https://${local.endpoint}/"
}

output "kibana_url" {
  description = "Kibana URL"
  value       = "https://${local.endpoint}/_plugin/kibana/"
}

output "security_group_id" {
  description = "ID of the Security Group attached to Elasticsearch"
  value       = aws_security_group.es.id
}
