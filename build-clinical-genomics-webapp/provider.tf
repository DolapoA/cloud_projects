# Author Dolapo Ajayi

terraform {
  cloud {
    organization = "dolapoa"
    workspaces {
      name = "build-clinical-genomics-webapp"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  required_version = ">= 1.2.0"
}

# Configure AWS provider
provider "aws" {
  region = var.aws_region
}
