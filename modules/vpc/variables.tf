# --------------------------------------------------------------------------------------------------
# VPC PARAMETERS
# --------------------------------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the all the VPC resources"
  default     = "My VPC"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC we will create"
  default     = "192.168.0.0/16"
}

// Convention is for the MSB of the third octet to be zero for public subnet and one for private
// subnets.

variable "vpc_public_subnets_cidr" {
  description = "CIDR for each of the subnets in the VPCs we want to create"
  type        = "list"
  default     = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "vpc_private_subnets_cidr" {
  description = "CIDR for each of the private subnets in the VPCs we want to create"
  type        = "list"
  default     = ["192.168.240.0/24", "192.168.241.0/24", "192.168.242.0/24"]
}

variable "vpc_database_subnets_cidr" {
  description = "A list of database subnets"
  type        = "list"
  default     = ["192.168.128.0/24", "192.168.129.0/24", "192.168.130.0/24"]
}

variable "vpc_azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type        = "list"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
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
