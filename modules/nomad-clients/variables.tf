# --------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------------------------------------------------

variable "ami_id" {
  description = "AMI ID for Nomad clients"
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
  description = "Name of the Nomad Clients cluster"
  default     = "nomad-client"
}

variable "instance_type" {
  description = "Type of instances to deploy Nomad servers to"
  default     = "t2.medium"
}

variable "clients_min" {
  description = "The minimum number of Nomad client nodes to deploy."
  default     = 3
}

variable "clients_desired" {
  description = "The desired number of Nomad client nodes to deploy."
  default     = 6
}

variable "clients_max" {
  description = "The max number of Nomad client nodes to deploy."
  default     = 8
}

variable "spot_price" {
  description = "Spot price of EC2 instance"
  default     = ""
}

variable "nomad_clients_services_inbound_cidr" {
  description = "A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the services hosted on Nomad clients on ports 20000 to 32000 will accept connections from."
  type        = list(string)
  default     = []
}

variable "user_data" {
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  # The default is at user_data/user-data-nomad-client.sh
  description = "The user data for the Nomad clients EC2 instances. If set to empty, the default template will be used"

  default = ""
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

variable "client_node_class" {
  description = "Nomad Client Node Class name for cluster identification"
  default     = "nomad-client"
}

variable "docker_privileged" {
  description = "Flag to enable privileged mode for Docker driver on Nomad client"
  default     = false
}

variable "docker_volumes_mounting" {
  description = "Flag to enable volume mounting for Docker driver on Nomad client"
  default     = false
}

variable "cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  default     = "consul-servers"
}

variable "consul_cluster_name" {
  description = "Name of the Consul cluster to deploy"
  default     = "consul-nomad-prototype"
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  default     = "Default"
}

# --------------------------------------------------------------------------------------------------
# Post Bootstrap Integration Parameters
# These parameters are used in conjunction with the other modules in this repository.
# If you change the values in the other modules, you have to update them too.
# --------------------------------------------------------------------------------------------------
variable "integration_consul_prefix" {
  description = <<EOF
  The Consul prefix used by the various integration scripts during initial instance boot.
EOF

  default = "terraform/"
}

variable "integration_service_type" {
  description = <<EOF
The 'server type' for this Nomad cluster. This is used in several integration.
If empty, this defaults to the `cluster_name` variable
EOF

  default = ""
}
