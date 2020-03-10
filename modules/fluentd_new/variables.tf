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
# ASG Required Parameters
# --------------------------------------------------------------------------------------------------

variable "ami_id" {
  description = "The ID of the AMI to run in this cluster. Should be an AMI that had Nomad installed and configured by the install-nomad module."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the cluster"
  type        = string
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad"
  type        = list(string)
}

variable "min_size" {
  description = "The minimum number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5."
  type        = number
}

variable "max_size" {
  description = "The maximum number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5."
  type        = number
}

variable "desired_capacity" {
  description = "The desired number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5."
  type        = number
}

# --------------------------------------------------------------------------------------------------
# ASG Optional Parameters
# --------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the cluster (e.g. nomad-servers-stage). This variable is used to namespace all resources created by this module."
  type        = string
  default     = "fluentd-servers"
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting. We remmend passing in a bash script that executes the run-nomad script, which should have been installed in the AMI by the install-nomad module."
  type        = string
  default     = " "
}

variable "asg_name" {
  description = "The name to use for the Auto Scaling Group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty."
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "The availability zones into which the EC2 Instances should be deployed. We recommend one availability zone per node in the cluster_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty."
  type        = list(string)
  default     = []
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections"
  type        = list(string)
  default     = []
}

variable "cluster_tag_key" {
  description = "Add a tag with this key and the value var.cluster_tag_value to each Instance in the ASG."
  type        = string
  default     = "nomad-servers"
}

variable "cluster_tag_value" {
  description = "Add a tag with key var.cluster_tag_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster."
  type        = string
  default     = "auto-join"
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  type        = string
  default     = "Default"
}

variable "associate_public_ip_address" {
  description = "If set to true, associate a public IP address with each EC2 Instance in the cluster."
  type        = bool
  default     = false
}

variable "tenancy" {
  description = "The tenancy of the instance. Must be one of: default or dedicated."
  type        = string
  default     = "default"
}

variable "root_volume_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  type        = string
  default     = "standard"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  type        = number
  default     = 50
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  default     = true
  type        = bool
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
  default     = "10m"
}

variable "health_check_type" {
  description = "Controls how health checking is done. Must be one of EC2 or ELB."
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time, in seconds, after instance comes into service before checking health."
  type        = number
  default     = 300
}

variable "instance_profile_path" {
  description = "Path in which to create the IAM instance profile."
  type        = string
  default     = "/"
}

variable "http_port" {
  description = "The port to use for HTTP"
  type        = number
  default     = 4646
}

variable "rpc_port" {
  description = "The port to use for RPC"
  type        = number
  default     = 4647
}

variable "serf_port" {
  description = "The port to use for Serf"
  type        = number
  default     = 4648
}

variable "ssh_port" {
  description = "The port used for SSH connections"
  type        = number
  default     = 22
}

variable "security_groups" {
  description = "Additional security groups to attach to the EC2 instances"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "List of extra tag blocks added to the autoscaling group configuration. Each element in the list is a map containing keys 'key', 'value', and 'propagate_at_launch' mapped to the respective values."
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []

}

variable "ebs_block_devices" {
  description = "List of ebs volume definitions for those ebs_volumes that should be added to the instances created with the EC2 launch-configuration. Each element in the list is a map containing keys defined for ebs_block_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device."
  # We can't narrow the type down more than "any" because if we use list(object(...)), then all the fields in the
  # object will be required (whereas some, such as encrypted, should be optional), and if we use list(map(...)), all
  # the values in the map must be of the same type, whereas we need some to be strings, some to be bools, and some to
  # be ints. So, we have to fall back to just any ugly "any."
  type    = any
  default = []
  # Example:
  #
  # default = [
  #   {
  #     device_name = "/dev/xvdh"
  #     volume_type = "gp2"
  #     volume_size = 300
  #     encrypted   = true
  #   }
  # ]
}

# --------------------------------------------------------------------------------------------------
#  LB Variables - Required
# --------------------------------------------------------------------------------------------------

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
