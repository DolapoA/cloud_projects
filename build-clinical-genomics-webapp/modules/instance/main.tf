# Author Dolapo Ajayi


# Using the latest Amazon Linux 2 AMI with a 5.10 kernel
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  user_data                   = file("${path.module}/init-script-cg-web-app.sh")

  ebs_block_device {
  device_name = "/dev/xvda"
  volume_size = 15
  volume_type = "gp3"
  delete_on_termination = true
  }

  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids

  tags = var.tags
}
