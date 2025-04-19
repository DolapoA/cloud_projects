variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

#variable "allowed_ingress_ports" {
#  description = "List of allowed ingress ports for the security group"
#  type        = list(number)
#  default     = [22, 80, 443, 3306]
#}

#variable "allowed_cidr_blocks" {
#  description = "List of CIDR blocks allowed for either ingress or egress traffic"
#  type        = list(string)
#  default     = ["0.0.0.0/0", "192.168.100.0/24"]
#}