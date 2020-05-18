# --------------------------------------------------------------------------------------------------
# Fluentd Config
# --------------------------------------------------------------------------------------------------

variable "fluentd_port" {
  description = "Port on the Docker image in which the HTTP interface is exposed"
  default     = 4224
}

variable "fluentd_api_domain" {
  description = "Domain to access Fluentd REST API"
}

# --------------------------------------------------------------------------------------------------
#  LB Variables - Required
# --------------------------------------------------------------------------------------------------

variable "lb_subnets" {
  description = "List of subnets to deploy the internal LB to"
  type        = list(string)
}

variable "lb_certificate_arn" {
  description = "ARN of the certificate to use for the internal LB"
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

# --------------------------------------------------------------------------------------------------
# LB Variables - Optional
# --------------------------------------------------------------------------------------------------

variable "lb_name" {
  description = "Name of the internal load balancer"
  default     = "fluentd-internal"
}

variable "tg_group_name" {
  description = "Name of the Fluentd server target group"
  default     = "fluentd-server-target-group"
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

variable "lb_tags" {
  description = "A map of tags to add to all resources"

  default = {
    Terraform   = "true"
    Environment = "development"
  }
}

variable "elb_ssl_policy" {
  description = "ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# --------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------------------------------------------------

variable "ami_id" {
  description = "AMI ID for Fluentd servers"
}

variable "vpc_id" {
  description = "ID of the VPC to deploy to"
}

variable "vpc_subnet_ids" {
  description = "List of Subnet IDs to deploy to"
  type        = list(string)
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients for API usage"
  type        = list(string)
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the Fluentd Server cluster"
  default     = "fluentd-server"
}

variable "instance_type" {
  description = "Type of instances to deploy Nomad servers to"
  default     = "t2.medium"
}

variable "min_size" {
  description = "The minimum number of Fluentd server nodes to deploy."
  default     = 1
}

variable "desired_size" {
  description = "The desired number of Fluentd server nodes to deploy."
  default     = 2
}

variable "max_size" {
  description = "The max number of Fluentd server nodes to deploy."
  default     = 5
}

variable "services_inbound_cidr" {
  description = "A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the Fluentd server on ports 20000 to 32000 will accept connections from."
  type        = list(string)
  default     = []
}

variable "user_data" {
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  description = "The user data for the Fluentd server EC2 instances. If set to empty, the default template will be used"
  default     = ""
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "gp2"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "associate_public_ip_address" {
  description = "If set to true, associate a public IP address with each EC2 Instance in the cluster."
  default     = true
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections"
  type        = list(string)
  default     = []
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  default     = "Default"
}
