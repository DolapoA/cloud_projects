# Author Dolapo Ajayi
# Date: 21.03.2025

provider "aws" {
  region = var.aws_region
}

# Filter for AZs that are available
data "aws_availability_zones" "available" {
  state = "available"
}

# Configure VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0" # updated to the latest on terraform registry - 13.03.2025

  cidr = var.vpc_cidr_block # allocates 65536 IP addresses for the VPC

 # AZs that are available
  azs             = data.aws_availability_zones.available.names

  # 2 private and 2 public subnets, each with 256 IP addresses
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)  

  # Enable NAT gateway for instances to enable security updates
  enable_nat_gateway = true
  
  # Enable VPN gateway into the VPC
  enable_vpn_gateway = true

  tags = var.resource_tags
}

############################################
# Enforce access to VPC via VPN exlusively #
############################################

# Create a VPN connection
resource "aws_vpn_connection" "cg_vpn" { #clinical genomics vpn
  customer_gateway_id = aws_customer_gateway.cg_vpn.id
  # Once connected it encrypts data between the user and the VPN gateway
  # This way activity is kept confidential
  type                = "ipsec.1"
  vpn_gateway_id      = aws_vpn_gateway.cg_vpn.id
  
  # Only allow routes to the VPC that admin is aware of
  # providing tighter control
  static_routes_only = true

  tags = {
    Name = "example-vpn-connection"
  }
}

# The route table (router) directs traffic through the VPN gateway
resource "aws_route" "vpn_route" {
  # Declare the route table to be used  
  route_table_id         = aws_route_table.private.id
  # Traffic from the internet...
  destination_cidr_block = "0.0.0.0/0"
  # ...Is directd through the VPN gateway
  gateway_id             = aws_vpn_gateway.cg_vpn.id
}

# Configure security groups to allow traffic only from the VPN connection
resource "aws_security_group" "vpn_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    # The rule refers to all ports
    from_port   = 0
    to_port     = 0
    # The rule relates to all protocols
    protocol    = "-1"
    # The rule allows traffic from the VPN connection
    cidr_blocks = [aws_vpn_connection.cg_vpn.customer_gateway_configuration]
  }

  egress {
    # This enables users to access the internet as usual
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-sg"
  }
}

# Define the network ACL
resource "aws_network_acl" "cg" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "cg-network-acl"
  }
}

# Configure network ACLs to allow traffic only from the VPN connection
resource "aws_network_acl_rule" "vpn_acl_rule_inbound" {
  network_acl_id = aws_network_acl.cg.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  cidr_block     = aws_vpn_connection.cg_vpn.customer_gateway_configuration
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "vpn_acl_rule_outbound" {
  network_acl_id = aws_network_acl.cg.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  rule_action         = "allow"
}
############################################
# | | | | | | | | | | | | | | | | | | | |  #
############################################

# Use random string to generate a unique ID for the load balancer
resource "random_string" "lb_id" {
  length  = 3
  special = false
}

resource "aws_lb_target_group" "cg-instance" {
  name     = "cg_instance-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = var.resource_tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.14.0" # Latest version 22.03.2025

  # Ensure load balancer name is unique
  name = "web-alb-${random_string.lb_id.result}"
  # The VPC this ALB belongs to
  vpc_id = module.vpc.vpc_id
  # The subnets the ALB is deployed to
  subnets = module.vpc.public_subnets
    # The security group for the ALB
    security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }
   # This stores logs in the named S3 bucket
   access_logs = {
    bucket = "my-alb-logs"
  }

  listeners = {
    cg-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      # HTTP traffic is redirected to HTTPS
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        # The status code for the redirect indicates permanent redirection
        status_code = "HTTP_301"
      }
    }
    # Ultimately, the ALB listens for HTTPS traffic
    cg-https = {
      port            = 443
      protocol        = "HTTPS"
      # The Amazon Resource Name (ARN) of the SSL/TLS certificate used to encrypt HTTPS traffic, 
      # it's stored in AWS IAM
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

    # The target group for the ALB, 
    forward = {
        target_group_key = "cg-instance"
      }
    }
  }

  tags = var.resource_tags
}


# Configure security modules for EC2 instances, 
# ALB, MySQL DB and the AWS Client VPN 


