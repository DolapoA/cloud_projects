variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable alb_arn = {
  description = "The ARN of the ALB"
  type        = string
}

variable "launch_template_name" {
  description = "The name of the launch template"
  type        = string
  default     = "internal-webapp-lt"
}