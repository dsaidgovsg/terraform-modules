output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${module.vpc.vpc_cidr_block}"
}

output "vpc_public_subnets" {
  description = "Public subnets for the VPC"
  value       = "${module.vpc.public_subnets}"
}

output "vpc_private_subnets" {
  description = "Public subnets for the VPC"
  value       = "${module.vpc.private_subnets}"
}

output "vpc_database_subnets" {
  description = "List of IDs of database subnets"
  value       = "${module.vpc.database_subnets}"
}

output "vpc_database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = "${module.vpc.database_subnets_cidr_blocks}"
}

output "vpc_database_subnet_group" {
  description = "ID of database subnet group"
  value       = "${module.vpc.database_subnet_group}"
}

output "vpc_public_route_tables" {
  description = "The IDs of the public route tables"
  value       = "${module.vpc.public_route_table_ids}"
}

output "vpc_private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = "${module.vpc.private_route_table_ids}"
}

output "vpc_azs" {
  description = "The AZs in the region the VPC belongs to"
  value       = "${var.vpc_azs}"
}

output "region" {
  description = "The region the VPC belongs to"
  value       = "${data.aws_region.current.name}"
}
