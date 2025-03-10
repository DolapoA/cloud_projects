# A configuration file for spinning up an EC2 instance with a Debian OS
# Author - Dolapo

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16" # Ensures compatibility with AWS provider version 4.16 and above
    }
  }
  required_version = ">= 1.2.0" # Requires Terraform version 1.2.0 or newer
}

provider "aws" {
  region = "us-east-1" # Sets the AWS region to North Virginia (us-east-1)
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true       # retrieves the latest AMI
  owners      = ["amazon"] # filters AMIs to only include official Amazon owned images

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"] # Matches the latest Ubuntu Server AMI pattern
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu_latest.id # Dynamically fetches the latest Ubuntu Server AMI ID
  instance_type = "t2.micro"                    # Uses t2.micro which is AWS Free Tier eligible

  root_block_device {
    volume_size = 8     # Ensures the root volume does not exceed AWS Free Tier 30GB limit
    volume_type = "gp2" # Uses general-purpose SSD which is AWS Free Tier eligible
  }

  tags = {
    Name = "ExampleAppServerInstance" # Assigns a name tag for easy identification
  }
}
