# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "public_dns_name" {
  description = "Public DNS names of the load balancer for this project"
  value       = module.elb_http.elb_dns_name
}

output "db_connect_string" {
  description = "MySQL database connection string"
  value       = "Server${aws_db_instance.database.address}; Database=BasicDB; Uid=${var.db_username}; Pwd=${var.db_password}"
  sensitive   = true
}