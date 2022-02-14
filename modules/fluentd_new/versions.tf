terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.0"
    }
  }
}
