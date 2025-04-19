output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

#output "db_connect_string" {
#  description = "MySQL database connection string"
#  value       = "Server${aws_db_instance.database.address}; Database=BasicDB; Uid=${var.db_username}; Pwd=${var.db_password}"
#  sensitive   = true
#}
