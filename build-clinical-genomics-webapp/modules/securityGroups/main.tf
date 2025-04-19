######################################################
# Provision security groups for respective resources #
######################################################

# Configure security modules for EC2 instances, 
# ALB, MySQL DB and the AWS Client VPN 

# Configure security group of ASG to allow traffic only from the ALB
#resource "aws_security_group" "asg_sg" {
#  name        = "asg-security-group"
#  description = "Security group for the Auto Scaling Group"
#  vpc_id      = module.vpc.vpc_id
#
#  ingress {
#    # Allow traffic from the ALB on HTTP (port 80)
#    from_port   = var.allowed_ingress_ports[1]
#    to_port     = var.allowed_ingress_ports[1]
#    # Transmission Control Protocol offers secure, reliable, accurate communication
#    # in the correct order between devices and applications like web servers, databases
#    # and file transfers
#    protocol    = "tcp"
#    security_groups = [module.alb.security_group_id]
#  }
#
#  ingress {
#    # Allow traffic from the ALB on HTTPS (port 443)
#    from_port   = var.allowed_ingress_ports[2]
#    to_port     = var.allowed_ingress_ports[2]
#    protocol    = "tcp"
#    security_groups = [module.alb.security_group_id]
#  }
#
#  egress {
#    # This enables instances to access the internet as usual
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = var.allowed_cidr_blocks[0]
#  }
#
#  tags = {
#    Name = "asg-sg"
#  }
#}

# Configure security group for the EC2 instances
resource "aws_security_group" "ec2_sg" {
  name = "ec2-security-group"
  description = "Security group for EC2 instances"
  vpc_id = var.vpc_id
  # Allow traffic from the ALB on HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #security_groups = [module.alb.security_group_id]
  }

}

# Configure security group for the ALB
#resource "aws_security_group" alb_sg {
#  name = "alb-security-group"
#  description = "Security group for the ALB"
#  vpc_id = module.vpn.vpc_id
#  # Allow traffic from the VPN connection on HTTP (port 80)
#    ingress {
#      from_port   = var.allowed_ingress_ports[1]
#      to_port     = var.allowed_ingress_ports[1]
#      protocol = "tcp"
#      description = "HTTP web traffic"
#      cidr_blocks   = var.allowed_cidr_blocks[1]
#    }
#
#    ingress {
#      from_port   = var.allowed_ingress_ports[2]
#      to_port     = var.allowed_ingress_ports[2]
#      protocol = "tcp"
#      description = "HTTPS web traffic"
#      cidr_blocks   = var.allowed_cidr_blocks[1]
#    }
#
#  egress = {
#    from_port = 0
#    to_port   = 0
#    protocol  = "-1"
#    cidr_blocks = var.allowed_cidr_blocks[1]
#  }
#
#  tags = {
#    Name = "alb-sg"
#  }
#}

# Configure security group for the MySQL-DB
#resource "aws_security_group" "mysql_sg" {
#  name        = "mysql-security-group"
#  description = "Security group for MySQL database"
#  vpc_id      = module.vpc.vpc_id
#
#  ingress {
#    # Allow traffic from the EC2 instances on MySQL port (3306)
#    from_port   = var.allowed_ingress_ports[3]
#    to_port     = var.allowed_ingress_ports[3]
#    protocol    = "tcp"
#    security_groups = [aws_security_group.ec2_sg.id]
#  }
#
#  egress {
#    # Allow all outbound traffic
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = var.allowed_cidr_blocks[1]
#  }
#
#  tags = {
#    Name = "mysql-sg"
#  }
#}