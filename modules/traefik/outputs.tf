output "traefik_external_zone" {
  description = "Route 53 Zone for the External Traefik LB endpoint"
  value       = "${data.aws_route53_zone.default.name}"
}

output "traefik_external_cname" {
  description = "URL that applications should set a CNAME record to for Traefik reverse proxy"
  value       = "${var.traefik_external_base_domain}"
}

output "traefik_external_lb_zone" {
  description = "The canonical hosted zone ID of the external load balancer (to be used in a Route 53 Alias record). "
  value       = "${aws_lb.external.zone_id}"
}

output "traefik_internal_zone" {
  description = "Route 53 Zone for the External internal LB endpoint"
  value       = "${data.aws_route53_zone.default.name}"
}

output "traefik_internal_cname" {
  description = "URL that applications should set a CNAME record to for Traefik reverse proxy"
  value       = "${var.traefik_internal_base_domain}"
}

output "traefik_internal_lb_zone" {
  description = "The canonical hosted zone ID of the internal load balancer (to be used in a Route 53 Alias record). "
  value       = "${aws_lb.internal.zone_id}"
}

output "traefik_jobspec" {
  description = "Nomad Jobspec for the deployed Traefik reverse proxy"
  value       = "${data.template_file.traefik_jobspec.rendered}"
}

output "traefik_lb_external_https_listener_arn" {
  description = "ARN of the HTTPS listener for the external load balancer"
  value       = "${aws_lb_listener.https_external.arn}"
}

output "traefik_lb_internal_https_listener_arn" {
  description = "ARN of the HTTPS listener for the internal load balancer"
  value       = "${aws_lb_listener.internal_https.arn}"
}
