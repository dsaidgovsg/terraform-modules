variable "ami_id" {
  description = "AMI ID for Nexus Server"
  default     = ""
}

variable "ssh_key_name" {
  description = "Name of SSH key to assign to the instance"
}

variable "subnet_id" {
  description = "Subnet ID to deploy the instance to"
}

variable "consul_security_group_id" {
  description = "Security Group ID for Consul servers"
}

variable "data_volume_id" {
  description = "EBS Volume ID for Nexus Data Storage"
}

variable "name" {
  description = "Base name for resources"
  default     = "nexus"
}

variable "subdomain" {
  description = "Subdomain for Nexus server"
  default     = "nexus"
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address for instance"
  default     = false
}

variable "instance_type" {
  description = "Type of instance to deploy"
  default     = "c5.large"
}

variable "nexus_service" {
  description = "Name of Nexus server service to register in Consul."
  default     = "nexus"
}

variable "nexus_db_dir" {
  description = "Path where the data for Nexus will be stored. This will be where the EBS volume where data is persisted will be mounted."
  default     = "/opt/sonatype/sonatype-work"
}

variable "nexus_port" {
  description = "Port at which the server will be listening to."
  default     = "8081"
}

variable "nexus_ami_prefix" {
  description = "AMI ID prefix for Nexus"
  default     = "nexus"
}

variable "data_device_name" {
  description = "Path of the EBS device that is mounted"
  default     = "/dev/nvme1n1"
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of allowed CIDR blocks to allow SSH access"
  default     = []
}

variable "additional_cidr_blocks" {
  description = "Additional CIDR blocks other than the VPC CIDR block thatn can access the Nexus server"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"

  default = {
    Terraform = "true"
  }
}

variable "root_volume_size" {
  description = "Size of the Nexus server root volume in GB"
  default     = 50
}

variable "consul_cluster_tag_key" {
  description = "Key that Consul Server Instances are tagged with for discovery"
  default     = "consul-servers"
}

variable "consul_cluster_tag_value" {
  description = "Value that Consul Server Instances are tagged with for discovery"
  default     = "consul"
}

variable "data_volume_mount" {
  description = "Data volume mount device name"
  default     = "/dev/sdf"
}

# --------------------------------------------------------------------------------------------------
# Traefik Integration
# --------------------------------------------------------------------------------------------------

variable "traefik_enabled" {
  description = "Enable Traefik Integration"
  default     = false
}

variable "traefik_entrypoints" {
  description = "List of entrypoints for Traefik"
  type        = list(string)

  # Default "internal" entrypoint
  default = ["internal"]
}

variable "traefik_fqdns" {
  description = "List of FQDNs for Traefik to listen to. You have to create the DNS records separately."
  type        = list(string)
  default     = []
}

# --------------------------------------------------------------------------------------------------
# AWS Auth Integration
# --------------------------------------------------------------------------------------------------
variable "aws_auth_enabled" {
  description = "Enable AWS Authentication"
  default     = false
}

variable "aws_auth_path" {
  description = "Path to the Vault AWS Authentication backend"
  default     = "aws"
}

variable "aws_auth_vault_role" {
  description = "Name of the role in the AWS Authentication backend to create"
  default     = "nexus"
}

variable "aws_auth_policies" {
  description = "List of Vault policies to assign to the tokens issued by the AWS authentication backend"
  type        = list(string)
  default     = []
}

variable "aws_auth_period_minutes" {
  description = "Period, in minutes, that the Vault token issued will live for"
  default     = "60"
}

# --------------------------------------------------------------------------------------------------
# Vault SSH Integration
# --------------------------------------------------------------------------------------------------

variable "vault_ssh_enabled" {
  description = "Enable Vault SSH integration"
  default     = false
}

variable "vault_ssh_path" {
  description = "Path to mount the SSH secrets engine"
  default     = "ssh_nexus"
}

variable "vault_ssh_role_name" {
  description = "Role name for the Vault SSH secrets engine"
  default     = "default"
}

variable "vault_ssh_user" {
  description = "Username to allow SSH access"
  default     = "ubuntu"
}

variable "vault_ssh_ttl" {
  description = "TTL for the Vault SSH certificate in seconds"
  default     = 300
}

variable "vault_ssh_max_ttl" {
  description = "Max TTL for certificate renewal"
  default     = 86400
}

# --------------------------------------------------------------------------------------------------
# td-agent Integration
# --------------------------------------------------------------------------------------------------

variable "td_agent_enabled" {
  description = "Enable td-agent integration. You will still need to provide the appropriate configuration file for td-agent during the AMI building process."
  default     = false
}

# --------------------------------------------------------------------------------------------------
# Curator Integration
# --------------------------------------------------------------------------------------------------
variable "curator_enable" {
  description = "Enable Curator integration for Nexus"
  default     = false
}

variable "curator_age" {
  description = "Age in days to retain indices"
  default     = "90"
}

variable "curator_prefix" {
  description = "Elasticsearch prefix for Curator logs"
  default     = "services.nexus"
}

# --------------------------------------------------------------------------------------------------
# CORE INTEGRATION SETTINGS
# --------------------------------------------------------------------------------------------------
variable "consul_key_prefix" {
  description = <<EOF
        Path prefix to the key in Consul to set for the `core` module to know that this module has
        been applied. If you change this, you have to update the
        `integration_consul_prefix` variable in the core module as well.
EOF

  default = "terraform/"
}

variable "server_type" {
  description = "Server type for the various types of modules integration"
  default     = "nexus"
}
