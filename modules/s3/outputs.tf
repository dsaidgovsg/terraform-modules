output "name" {
  description = "Name of AWS EC2 Container Registry repository"
  value       = aws_ecr_repository.default.name
}

output "arn" {
  description = "Full ARN of AWS EC2 Container Registry repository"
  value       = aws_ecr_repository.default.arn
}

output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = aws_ecr_repository.default.registry_id
}

output "repository_url" {
  description = "The URL of the repository, in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName"
  value       = aws_ecr_repository.default.repository_url
}

output "service_url" {
  description = "The URL of the repository service, in the form aws_account_id.dkr.ecr.region.amazonaws.com"
  value       = local.service_url
}

output "subdomain" {
  description = "Subdomain domain of the A record"
  value       = var.route53_domain
}
