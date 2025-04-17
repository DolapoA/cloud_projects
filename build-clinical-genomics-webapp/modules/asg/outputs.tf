output "asg_security_group_id" {
  description = "The ID of the security group for the ASG"
  value       = aws_security_group.asg_sg.id
}