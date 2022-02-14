terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42, < 4.0.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 1.4"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.0"
    }
  }
}
