# Author Dolapo Ajayi

# Filter for AZs that are available
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block 
  private_subnet_cidr_blocks = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnet_cidr_blocks = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)  
}


###############################################
# Provision resources for the web application #
###############################################

#----------------------------------------#
# Resources provisioned - ALB, EC2s, ASG #
#----------------------------------------#


module "alb" {
  source = "./modules/alb"

  # The VPC this ALB belongs to
  vpc_id = module.vpc.vpc_id
  # The subnets the ALB is deployed to
  subnets = module.vpc.public_subnets

  alb_arn = module.alb.alb_arn
  
}

# Provision EC2 instances
module "ec2_instances" {
  source = "./modules/instance"

  depends_on = [module.vpc]
  # Number of instances to provision
  instance_count     = var.instance_count
  # The type of EC2 instance to provision
  instance_type      = var.instance_type
  # The subnets to which the EC2(s) belong
  subnet_ids         = module.vpc.private_subnets[*]
  # The associated security group for the EC2s
  security_group_ids = [module.app_security_group.security_group_id]

  tags = var.resource_tags
}

module "asg" {
  source = "./modules/asg"

  # The VPC this ASG belongs to
  vpc_id = module.vpc.vpc_id
  # The subnets the ASG is deployed to
  subnets = module.vpc.private_subnets

  # The ALB this ASG is associated with
  alb_arn = module.alb.alb_arn

  # The security group for the ASG
  security_group_ids = [module.security_group_id]
}

module "rdbms" {
  source = "./modules/rdbms"

  # The VPC this RDBMS belongs to
  vpc_id = module.vpc.vpc_id

  # The subnets the RDBMS is deployed to
  subnets = module.vpc.private_subnets

  # The security group for the RDBMS
  security_group_ids = [module.security_group_id]

  # The database admin username and password
  db_username = var.db_username
  db_password = var.db_password

  tags = var.resource_tags
}

######################################################
# Provision security groups for respective resources #
######################################################

# Configure security modules for EC2 instances, 
# ALB, MySQL DB and the AWS Client VPN 

# Configure security group of ASG to allow traffic only from the ALB
resource "aws_security_group" "asg_sg" {
  name        = "asg-security-group"
  description = "Security group for the Auto Scaling Group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    # Allow traffic from the ALB on HTTP (port 80)
    from_port   = 80
    to_port     = 80
    # Transmission Control Protocol offers secure, reliable, accurate communication
    # in the correct order between devices and applications like web servers, databases
    # and file transfers
    protocol    = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  ingress {
    # Allow traffic from the ALB on HTTPS (port 443)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  egress {
    # This enables instances to access the internet as usual
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-sg"
  }
}

# Configure security group for the EC2 instances
resource "aws_security_group" "ec2_sg" {
  name = "ec2-security-group"
  description = "Security group for EC2 instances"
  vpc_id = module.vpc.vpc_id
  # Allow traffic from the ALB on HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [module.alb.security_group_id]
  }

}

# Configure security group for the ALB
resource "aws_security_group" alb_sg {
  name = "alb-security-group"
  description = "Security group for the ALB"
  vpc_id = module.vpn.vpc_id
  # Allow traffic from the VPN connection on HTTP (port 80)
    ingress {
      from_port   = 80
      to_port     = 80
      protocol = "tcp"
      description = "HTTP web traffic"
      cidr_blocks   = ["192.168.100.0/24"]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_blocks   = ["192.168.100.0/24"]
    }

  egress = {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["192.168.100.0/24"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Configure security group for the MySQL-DB
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Security group for MySQL database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    # Allow traffic from the EC2 instances on MySQL port (3306)
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    # Allow all outbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.100.0/24"]
  }

  tags = {
    Name = "mysql-sg"
  }
}