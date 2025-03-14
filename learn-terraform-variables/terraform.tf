# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {


  cloud {
    organization = "dolapoa"
    workspaces {
      name = "learn-terraform-variables"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.1"
    }
  }
  required_version = "~> 1.2"
}
