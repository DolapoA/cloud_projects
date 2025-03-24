output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.app.*.id
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.amazon_linux.id
}

output "instance_type" {
  description = "Outputs instance type"
  value       = var.instance_type
}