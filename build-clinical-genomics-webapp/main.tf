module "vpc" {
  source                     = "./modules/vpc"
  vpc_cidr_block             = var.vpc_cidr_block
  private_subnet_cidr_blocks = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnet_cidr_blocks  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)
}

######################

# Provision of web application resources 
# Resources provisioned: ALB, EC2s, ASG, RDBMS

#module "alb" {
#  source = "./modules/alb"

#  # The VPC this ALB belongs to
#  vpc_id = var.vpc_id
#  # The subnets the ALB is deployed to
#  subnets = var.subnets
#
#  alb_arn = module.alb.alb_arn
#
#}

# Provision EC2 instances
module "ec2_instances" {
  source = "./modules/instance"

  depends_on = [module.vpc]
  # Number of instances to provision
  instance_count = var.instance_count
  # The type of EC2 instance to provision
  instance_type = var.instance_type
  # The subnets to which the EC2(s) belong
  subnet_ids = module.vpc.private_subnets[*]
  # The associated security group for the EC2s
  security_group_ids = [module.security_groups.ec2_sg_id]

  tags = var.resource_tags
}

#module "asg" {
#  source = "./modules/asg"
#
#  # The VPC this ASG belongs to
#  vpc_id = module.vpc.vpc_id
#  # The subnets the ASG is deployed to
#  subnets = module.vpc.private_subnets
#
#  # The ALB this ASG is associated with
#  alb_arn = module.alb.alb_arn
#
#  # The security group for the ASG
#  security_group_ids = [module.security_groups.security_group_id]
#}

#module "rdbms" {
#  source = "./modules/rdbms"
#
#  # The VPC this RDBMS belongs to
#  vpc_id = module.vpc.vpc_id
#
#  # The subnets the RDBMS is deployed to
#  subnets = module.vpc.private_subnets
#
#  # The security group for the RDBMS
#  security_group_ids = [module.security_groups.security_group_id]
#
#  # The database admin username and password
#  db_username = var.db_username
#  db_password = var.db_password
#
#  tags = var.resource_tags
#}

######################

# Provisioning of security groups
module "security_groups" {
  source = "./modules/securityGroups"

  # The VPC this security group belongs to
  vpc_id = module.vpc.vpc_id

}