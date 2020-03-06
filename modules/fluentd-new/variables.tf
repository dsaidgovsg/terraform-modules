# --------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------------------------------------------------

variable "vpc_id" {
  description = "ID of the VPC to launch the module in"
}

variable "fluentd_server_ami_id" {
  description = "AMI ID for Fluentd server"
}

variable "fluentd_subnets" {
  description = "List of subnets to launch Fluentd servers in"
  type        = list(string)
}

variable "lb_subnets" {
  description = "List of subnets to deploy the internal LB to"
  type        = list(string)
}

variable "route53_zone" {
  description = "Zone for Route 53 records"
}

variable "add_private_route53_zone" {
  description = "Setting to true adds a new Route53 zone under the same domain name as `route53_zone`, but in a private zone, on top of the default public one"
  default     = false
}

variable "lb_incoming_cidr" {
  description = "A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to"
  type        = list(string)
}

variable "fluentd_api_domain" {
  description = "Domain to access Fluentd REST API"
}

# --------------------------------------------------------------------------------------------------
# Internal LB Variables
# --------------------------------------------------------------------------------------------------

variable "lb_name" {
  description = "Name of the internal load balancer"
  default     = "fluentd-internal"
}

variable "fluentd_server_lb_deregistration_delay" {
  description = "The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining."
  default     = 30
}

variable "lb_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10)."
  default     = 2
}

variable "lb_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering a target unhealthy (2-10)."
  default     = 2
}

variable "lb_health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  default     = 30
}

variable "lb_access_log" {
  description = "Log Internal LB access to a S3 bucket"
  default     = false
}

variable "lb_access_log_bucket" {
  description = "S3 bucket to log access to the internal LB to"
}

variable "lb_access_log_prefix" {
  description = "Prefix in the S3 bucket to log internal LB access"
  default     = ""
}

variable "lb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Consul supports blocking requests that can last up to 600 seconds. Increase this to support that."
  default     = 660
}

# --------------------------------------------------------------------------------------------------
# Fluentd Config Variables
# --------------------------------------------------------------------------------------------------

variable "fluentd_image" {
  description = "Docker image for fluentd"
  default     = "govtechsg/fluentd-s3-elasticsearch"
}

variable "fluentd_tag" {
  description = "Tag for fluentd Docker image"
  default     = "1.2.5-latest"
}

variable "fluentd_conf_file" {
  description = "Rendered fluentd configuration file"
  default     = "alloc/config/fluent.conf"
}

variable "fluentd_force_pull" {
  description = "Force pull an image. Useful if the tag is mutable."
  default     = "false"
}

variable "fluentd_count" {
  description = "Number of copies of Fluentd to run"
  default     = 3
}
