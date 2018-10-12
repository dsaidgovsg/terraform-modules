variable "route53_zone" {
  description = "Zone for Route 53 records"
}

variable "external_certificate_arn" {
  description = "ARN for the certificate to use for the external LB"
}

variable "internal_certificate_arn" {
  description = "ARN for the certificate to use for the internal LB"
}

variable "traefik_external_base_domain" {
  description = "Domain to expose the external Traefik load balancer"
}

variable "traefik_internal_base_domain" {
  description = "Domain to expose the external Traefik load balancer"
}

variable "traefik_ui_domain" {
  description = "Domain to access Traefik UI"
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the LB to"
}

variable "lb_external_subnets" {
  description = "List of subnets to deploy the external LB to"
  type        = "list"
}

variable "lb_internal_subnets" {
  description = "List of subnets to deploy the internal LB to"
  type        = "list"
}

variable "nomad_clients_node_class" {
  description = "Job constraint Nomad Client Node Class name"
}

variable "nomad_clients_external_security_group" {
  description = "The security group of the nomad clients that the external LB will be able to connect to"
}

variable "nomad_clients_internal_security_group" {
  description = "The security group of the nomad clients that the internal LB will be able to connect to"
}

variable "external_nomad_clients_asg" {
  description = "The Nomad Clients Autoscaling group to attach the external load balancer to"
}

variable "internal_nomad_clients_asg" {
  description = "The Nomad Clients Autoscaling group to attach the internal load balancer to"
}

#########################################
# Optional Variables
#########################################

variable "external_lb_name" {
  description = "Name of the external Nomad load balancer"
  default     = "traefik-external"
}

variable "internal_lb_name" {
  description = "Name of the external Nomad load balancer"
  default     = "traefik-internal"
}

variable "tags" {
  description = "A map of tags to add to all resources"

  default = {
    Terraform   = "true"
    Environment = "development"
  }
}

variable "external_lb_incoming_cidr" {
  description = "A list of CIDR-formatted IP address ranges from which the external Load balancer is allowed to listen to"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "internal_lb_incoming_cidr" {
  description = "A list of CIDR-formatted IP address ranges from which the internal load balancer is allowed to listen to"
  type        = "list"
  default     = []
}

variable "deregistration_delay" {
  description = "Time before an unhealthy Elastic Load Balancer target becomes removed"
  default     = 60
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10)."
  default     = 2
}

variable "timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check (2-60 seconds)."
  default     = 5
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering a target unhealthy (2-10)."
  default     = 2
}

variable "interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  default     = 30
}

variable "elb_ssl_policy" {
  description = "ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "traefik_version" {
  description = "Docker image tag of the version of Traefik to run"
  default     = "v1.6.5-alpine"
}

variable "traefik_priority" {
  description = "Priority of the Nomad job for Traefik. See https://www.nomadproject.io/docs/job-specification/job.html#priority"
  default     = 50
}

variable "traefik_consul_prefix" {
  description = "Prefix on Consul to store Traefik configuration to"
  default     = "traefik"
}

variable "traefik_consul_catalog_prefix" {
  description = "Prefix for Consul catalog tags for Traefik"
  default     = "traefik"
}

variable "traefik_count" {
  description = "Number of copies of Traefik to run"
  default     = 3
}

variable "additional_docker_config" {
  description = "Additional HCL to be added to the configuration for the Docker driver. Refer to the template Jobspec for what is already defined"
  default     = ""
}

variable "log_json" {
  description = "Log in JSON format"
  default     = false
}

variable "access_log_enable" {
  description = "Enable access logging"
  default     = true
}

variable "access_log_json" {
  description = "Log access in JSON"
  default     = false
}

variable "lb_external_access_log" {
  description = "Log External Traefik LB access to a S3 bucket"
  default     = false
}

variable "lb_external_access_log_bucket" {
  description = "S3 bucket to log access to the External Traefik LB to"
}

variable "lb_external_access_log_prefix" {
  description = "Prefix in the S3 bucket to log External Traefik LB access"
  default     = ""
}

variable "lb_internal_access_log" {
  description = "Log internal Traefik LB access to a S3 bucket"
  default     = false
}

variable "lb_internal_access_log_bucket" {
  description = "S3 bucket to log access to the internal Traefik LB to"
}

variable "lb_internal_access_log_prefix" {
  description = "Prefix in the S3 bucket to log internal Traefik LB access"
  default     = ""
}
