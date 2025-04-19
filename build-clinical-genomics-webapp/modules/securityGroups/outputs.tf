output "ec2_sg_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ec2_sg.id
}