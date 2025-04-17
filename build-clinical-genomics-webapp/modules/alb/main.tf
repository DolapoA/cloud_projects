# Configure the Application Load Balancer (ALB) to direct traffic to the target group
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.14.0" # Latest version 22.03.2025

  # Ensure load balancer name is unique
  name = "web-alb-${random_string.lb_id.result}"
  # The VPC this ALB belongs to
  vpc_id = module.vpc.vpc_id
  # The subnets the ALB is deployed to
  subnets = module.vpc.public_subnets

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

# Routes HTTP traffic from the ALB to the target group within the specified
# VPC
resource "aws_lb_target_group" "cg-instance" {
  name     = "cg_instance-target-group"
  # The type of traffic that the target group will handle
  port     = 80
  protocol = "HTTP"
  # The VPC this target group belongs to
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30 # The time between health checks
    timeout             = 5 # The time before a health check times out
    healthy_threshold   = 5 # The number of consecutive successful health checks
    unhealthy_threshold = 2 # The number of consecutive failed health checks
    matcher             = "200" # The HTTP response code that indicates a healthy target
  }

  tags = var.resource_tags
}

# Use random string to generate a unique ID for the load balancer
resource "random_string" "lb_id" {
  length  = 3
  special = false
}