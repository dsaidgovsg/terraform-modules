terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42, < 4.0.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.5"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 2.0"
    }
  }
}
