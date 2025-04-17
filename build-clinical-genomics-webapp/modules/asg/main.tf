# Provision the Auto Scaling Group (ASG)
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Basic ASG settings
  name                = "internal-webapp-asg"
  # The minimum and maximum number of instances that the ASG maintains
  min_size            = 0
  max_size            = 2
  # The default number of instances to provision
  desired_capacity    = 1
  # EC2 instance status checks
  health_check_type   = "EC2"
  vpc_zone_identifier = module.vpc.private_subnets[*]

  # Launch template essentials
  launch_template_name        = "internal-webapp-lt"
  # The launch template will be updated if a new version of the template is created
  update_default_version      = true
  # Refers to the module that provisions the EC2 instances
  image_id                    = module.instance.ami_id
  # Refers to variable defined in variables.tf and which has been exposed in outputs.tf
  instance_type               = module.instance.instance_type
  enable_monitoring           = true

  # IAM role for EC2 instance to obtain AWS Systems Manager (SSM) access
  # This creates an IAM instance profile that enables the instance to assume the
  # profile/role and gain the permissions defined herein i.e.internal-webapp-role
  create_iam_instance_profile = true
  iam_role_name               = "internal-webapp-role"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Block device (root volume)
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        # General purpose SSD
        volume_type           = "gp2"
      }
    }
  ]

  # Network interface mappings for the instances to be launched by the auto scaling group (main)
  network_interfaces = [
    {
      delete_on_termination = true
      # Index value 0 means that this is the primary network interface for the instance
      device_index          = 0
      security_groups       = [aws_security_group.asg_sg.id]
    }
  ]

  # Metadata options (security best practice)
  # These settings control how the 
  metadata_options = {
    http_endpoint               = "enabled"
    # [security measure] Enforced requirement of valid session tokens to access instance metadata to prevent
    # unauthorized access to metadata - mitigates theft of data in cases where a network has
    # been misconfigured
    http_tokens                 = "required"
    # [security measure] Only requests made from the instance itself can request metadata
    http_put_response_hop_limit = 1
  }

  # Tags
  tags = {
    Environment = "dev"
    Project     = "genomics-app"
  }
}