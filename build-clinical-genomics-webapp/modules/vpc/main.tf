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
