# Author Dolapo Ajayi
# Date: 21.03.2025

# AWS region suitable for a UK based organisation
variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "eu-west-2"
}

# Allocates 65536 IP addresses for the VPC
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# public CIDR blocks
variable "public_subnet_cidr_blocks" {
  description = "Public subnets in VPC"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

# private CIDR blocks
variable "private_subnet_cidr_blocks" {
  description = "Public subnets in VPC"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    project     = "clinical-genomics-web-app",
    environment = "dev"
  }

  validation {
    condition     = length(var.resource_tags["project"]) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["project"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.resource_tags["environment"]) <= 8 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["environment"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}

# Number of public subnets in VPC
variable "public_subnet_count" {
  description = "Number of public subnets in VPC"
  type        = number
  default     = 2
}

# Number of private subnets in VPC
variable "private_subnet_count" {
  description = "Number of private subnets in VPC"
  type        = number
  default     = 2
}

# Number of instances to provision
variable "instance_count" {
  default     = 2
}

variable "instance_type" {
  default     = "t2.micro"
}