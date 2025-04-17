resource "aws_db_instance" "database" {
  allocated_storage = 5
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name = aws_db_subnet_group.private.name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  skip_final_snapshot = true
}

# Provision the MySQL database
resource "aws_db_subnet_group" "private" {
  subnet_ids = module.vpc.private_subnets
}

