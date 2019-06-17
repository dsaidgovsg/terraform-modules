output "instance_id" {
  description = "Instance ID for the server"
  value       = "${aws_instance.nexus.id}"
}

output "instance_private_ip" {
  description = "Private IP address for the server"
  value       = "${aws_instance.nexus.private_ip}"
}

output "security_group_id" {
  description = "Security Group ID for the instance"
  value       = "${aws_security_group.nexus.id}"
}
