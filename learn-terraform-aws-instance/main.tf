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


resource "aws_instance" "app_server" {
  ami           = "ami-064519b8c76274859" # fetches a Debian AMI ID
  instance_type = "t2.micro"             # Uses t2.micro which is AWS Free Tier eligible

  root_block_device {
    volume_size = 8     # Ensures the root volume does not exceed AWS Free Tier 30GB limit
    volume_type = "gp2" # Uses general-purpose SSD which is AWS Free Tier eligible
  }

  tags = {
    Name = "ExampleAppServerInstance" # Assigns a name tag for easy identification
  }
}
