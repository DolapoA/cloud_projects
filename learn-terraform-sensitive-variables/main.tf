# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

# Filter for AZs that are available
data "aws_availability_zones" "available" {
  state = "available"
}

# Configure security modules first to ensure that it is in place before configuring infrastructure
# components like EC2 instances and load balancers
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0" # updated to the latest on terraform registry - 13.03.2025

  cidr = var.vpc_cidr_block # allocates 65536 IP addresses to 65536 components in the VPC

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count) # 2 private subnets, it allocates 256 IP addresses each
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)   # 2 public subnets, allocates 256 IP addresses each

  enable_nat_gateway = true # Enable NAT gateway for instances to enable security updates
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.resource_tags
}



module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "5.3.0" # updated to the latest on terraform registry - 13.03.2025

  name        = "web-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks # Allow traffic only from public subnets

  tags = var.resource_tags
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "5.3.0" # updated to the latest on terraform registry - 13.03.2025

  name        = "lb-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"] # Allows all traffic from the internet

  tags = var.resource_tags
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "db-sg"
  description = "Security group for MySQL database"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      description              = "Allow MySQL from EC2 SG"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.app_security_group.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = var.resource_tags
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.2" # updated to the latest on terraform registry - 13.03.2025

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"

  internal = false

  security_groups = [module.lb_security_group.security_group_id]
  subnets         = module.vpc.public_subnets

  number_of_instances = length(module.ec2_instances.instance_ids)
  instances           = module.ec2_instances.instance_ids

  listener = [{
    # Within the VPC, data flowing from the ELB to the instance need not be encrypted
    instance_port     = "80"
    instance_protocol = "HTTP"

    lb_port     = "80"
    lb_protocol = "HTTP"
  }]

  # Check instance health by sending HTTP requests
  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10 # number of seconds per check
    healthy_threshold   = 3  # number of consecutive successful checks for an instance to be considered healthy
    unhealthy_threshold = 10 # number of consecutive unsuccessful checks for an instance to be considered unhealthy
    timeout             = 5  # number of seconds to wait before declaring the health check as failed
  }

  tags = var.resource_tags
}

module "ec2_instances" {
  source = "./modules/aws-instance"

  depends_on = [module.vpc]

  instance_count     = var.instance_count
  instance_type      = var.ec2_instance_type
  subnet_ids         = module.vpc.private_subnets[*]
  security_group_ids = [module.app_security_group.security_group_id]

  tags = var.resource_tags
}

resource "aws_db_subnet_group" "private" {
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "database" {
  allocated_storage = 5
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name = aws_db_subnet_group.private.name

  skip_final_snapshot = true
}
