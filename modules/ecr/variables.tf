variable "name" {
  description = "Name of AWS EC2 Container Registry repository"
}

variable "add_route53_record" {
  description = "Flag to state whether to add additional A record into Route53"
  default     = true
}

variable "route53_zone_id" {
  description = "Zone ID to use for Route53 record. Only applicable if `add_route53_record` is `true`"
  default     = ""
}

variable "route53_domain" {
  description = "Domain to set as A record for Route53. Only applicable if `add_route53_record` is `true`"
  default     = ""
}

variable "lb_cname" {
  description = "DNS CNAME for the Load balancer. Only applicable if `add_route53_record` is `true`"
  default     = ""
}

variable "lb_zone_id" {
  description = "Zone ID for the Load balancer DNS CNAME. Only applicable if `add_route53_record` is `true`"
  default     = ""
}

variable "redirect_listener_arn" {
  description = "LB listener ARN to attach the rule to. Only applicable if `add_route53_record` is `true`"
  default     = ""
}

variable "redirect_rule_priority" {
  description = "Rule priority for redirect. Only applicable if `add_route53_record` is `true`"
  default     = 100
}

variable "tags" {
  description = "A map of tags to add to all resources"

  default = {
    Terraform = "true"
  }
}
