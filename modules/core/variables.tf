
# --------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------------------------------------------------

variable "nomad_clients_ami_id" {
    description = "AMI ID for Nomad clients"
}

variable "nomad_servers_ami_id" {
    description = "AMI ID for Nomad servers"
}

variable "consul_ami_id" {
    description = "AMI ID for Consul servers"
}

variable "consul_allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Consul servers for API usage"
  type        = "list"
}

variable "nomad_servers_allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Servers servers for API usage"
  type        = "list"
}

variable "nomad_clients_allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients servers for API usage"
  type        = "list"
}

variable "route53_zone" {
  description = "Zone for Route 53 records"
}

variable "internal_lb_incoming_cidr" {
  description = "A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to"
  type = "list"
}

# --------------------------------------------------------------------------------------------------
# Domain name variables
# --------------------------------------------------------------------------------------------------

variable "internal_lb_certificate" {
  description = "Domain name where certificate for the internal LB is issued under"
}

variable "nomad_api_domain" {
  description = "Domain to access Nomad REST API"
}

variable "consul_api_domain" {
  description = "Domain to access Consul HTTP API"
}

# --------------------------------------------------------------------------------------------------
# VPC PARAMETERS
# --------------------------------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the all the VPC resources"
  default = "My VPC"
}

variable "vpc_cidr" {
    description = "CIDR for the VPC we will create"
    default = "192.168.0.0/16"
}

// Convention is for the MSB of the third octet to be zero for public subnet and one for private
// subnets.

variable "vpc_public_subnets_cidr" {
  description = "CIDR for each of the subnets in the VPCs we want to create"
  type = "list"
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "vpc_private_subnets_cidr" {
  description = "CIDR for each of the private subnets in the VPCs we want to create"
  type = "list"
  default = ["192.168.240.0/24", "192.168.241.0/24", "192.168.242.0/24"]
}

variable "vpc_database_subnets_cidr" {
  description = "A list of database subnets"
  type = "list"
  default = ["192.168.128.0/24", "192.168.129.0/24", "192.168.130.0/24"]
}

variable "vpc_azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
    Terraform = "true"
    Environment = "development"
  }
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections"
  type        = "list"
  default     = []
}

variable "associate_public_ip_address" {
  description = "If set to true, associate a public IP address with each EC2 Instance in the cluster."
  default     = true
}

variable "nomad_cluster_name" {
  description = "The name of the Nomad cluster (e.g. nomad-servers-stage). This variable is used to namespace all resources created by this module."
  default = "consul-nomad-prototype"
}

variable "nomad_server_instance_type" {
    description = "Type of instances to deploy Nomad servers to"
    default = "t2.medium"
}

variable "nomad_client_instance_type" {
    description = "Type of instances to deploy Nomad servers to"
    default = "t2.medium"
}

variable "nomad_servers_num" {
  description = "The number of Nomad server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "nomad_clients_min" {
  description = "The minimum number of Nomad client nodes to deploy."
  default     = 3
}

variable "nomad_clients_desired" {
  description = "The desired number of Nomad client nodes to deploy."
  default     = 6
}

variable "nomad_clients_max" {
  description = "The max number of Nomad client nodes to deploy."
  default     = 8
}

variable "nomad_clients_services_inbound_cidr" {
  description = "A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the services hosted on Nomad clients on ports 20000 to 32000 will accept connections from."
  type        = "list"
  default     = []
}

variable "consul_cluster_name" {
    description = "Name of the Consul cluster to deploy"
    default = "consul-nomad-prototype"
}

variable "consul_cluster_size" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  default     = "consul-servers"
}

variable "consul_instance_type" {
    description = "Type of instances to deploy Consul servers and clients to"
    default = "t2.medium"
}

variable "internal_lb_name" {
  description = "Name of the internal Nomad load balancer"
  default = "nomad-internal"
}

variable "deregistration_delay" {
  description = "Time before an unhealthy Elastic Load Balancer target becomes removed"
  default = 30
}
