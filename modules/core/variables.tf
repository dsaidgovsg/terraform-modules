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

variable "vault_ami_id" {
  description = "AMI ID for Vault servers"
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

variable "vault_allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Vault servers for API usage"
  type        = "list"
}

variable "vault_tls_key_policy_arn" {
  description = "ARN of the IAM policy to allow the Vault EC2 instances to decrypt the encrypted TLS private key baked into the AMI. See README for more information."
}

variable "route53_zone" {
  description = "Zone for Route 53 records"
}

variable "internal_lb_incoming_cidr" {
  description = "A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to"
  type        = "list"
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

variable "vault_api_domain" {
  description = "Domain to access Vault HTTP API"
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------
variable "tags" {
  description = "A map of tags to add to all resources"

  default = {
    Terraform   = "true"
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
  default     = "consul-nomad-prototype"
}

variable "nomad_server_instance_type" {
  description = "Type of instances to deploy Nomad servers to"
  default     = "t2.medium"
}

variable "nomad_client_instance_type" {
  description = "Type of instances to deploy Nomad servers to"
  default     = "t2.medium"
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

variable "nomad_servers_root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "gp2"
}

variable "nomad_servers_root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "nomad_clients_root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "gp2"
}

variable "nomad_clients_root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "nomad_servers_user_data" {
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  # The default is at user_data/user-data-nomad-server.sh
  description = "The user data for the Nomad servers EC2 instances. If set to empty, the default template will be used"

  default = ""
}

variable "nomad_clients_user_data" {
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  # The default is at user_data/user-data-nomad-client.sh
  description = "The user data for the Nomad clients EC2 instances. If set to empty, the default template will be used"

  default = ""
}

variable "consul_cluster_name" {
  description = "Name of the Consul cluster to deploy"
  default     = "consul-nomad-prototype"
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
  default     = "t2.medium"
}

variable "consul_root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "gp2"
}

variable "consul_root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "consul_user_data" {
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  # The default is at user_data/user-data-consul-server.sh
  description = "The user data for the Consul servers EC2 instances. If set to empty, the default template will be used"

  default = ""
}

variable "vault_cluster_name" {
  description = "The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module."
  default     = "vault"
}

variable "vault_cluster_size" {
  description = "The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5."
  default     = 3
}

variable "vault_allowed_inbound_security_group_ids" {
  description = "A list of security group IDs that will be allowed to connect to Vault"
  type        = "list"
  default     = []
}

variable "vault_instance_type" {
  description = "The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro)."
  default     = "t2.medium"
}

variable "vault_root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "gp2"
}

variable "vault_root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "vault_enable_s3_backend" {
  description = "Whether to configure an S3 storage backend for Vault in addition to Consul."
  default     = false
}

variable "vault_s3_bucket_name" {
  description = "The name of the S3 bucket to create and use as a storage backend for Vault. Only used if 'vault_enable_s3_backend' is set to true."
  default     = ""
}

variable "vault_user_data" {
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  # The default is at user_data/user-data-consul-server.sh
  description = "The user data for the Vault servers EC2 instances. If set to empty, the default template will be used"

  default = ""
}

variable "internal_lb_name" {
  description = "Name of the internal load balancer"
  default     = "internal"
}

variable "deregistration_delay" {
  description = "Time before an unhealthy Elastic Load Balancer target becomes removed"
  default     = 30
}

variable "elb_ssl_policy" {
  description = "ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "vpc_region" {
  description = "The region the VPC belongs to"
  default     = ""
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
