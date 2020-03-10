#
# Consul related
#

variable "es_consul_service" {
  description = "Name to register in consul to identify Elasticsearch service"
  default     = "elasticsearch"
}

#
# ES access
#

variable "es_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
}

variable "es_default_access" {
  description = "Rest API / Web UI access"
  type        = map(any)

  default = {
    type     = "ingress"
    protocol = "tcp"
    port     = 443
  }
}

variable "es_post_access_cidr_block" {
  description = "Elasticsearch access CIDR block to allow access"
  type        = list(string)
}

variable "es_security_group_id" {
  description = "ID of the Security Group attached to Elasticsearch"
}

#
# Redirect related
#

variable "use_redirect" {
  description = "Indicates whether to use redirect users "
  default     = false
}

variable "redirect_route53_zone_id" {
  description = "Route53 Zone ID to create the Redirect Record in"
  default     = ""
}

variable "redirect_domain" {
  description = "Domain name to redirect"
  default     = ""
}

variable "lb_cname" {
  description = "DNS CNAME for the Load balancer"
  default     = ""
}

variable "lb_zone_id" {
  description = "Zone ID for the Load balancer DNS CNAME"
  default     = ""
}

variable "redirect_listener_arn" {
  description = "LB listener ARN to attach the rule to"
  default     = ""
}

variable "redirect_rule_priority" {
  description = "Rule priority for redirect"
  default     = 100
}
