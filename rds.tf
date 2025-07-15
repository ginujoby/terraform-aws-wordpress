# DB Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

# RDS Instance
resource "aws_db_instance" "wordpress" {
  identifier          = "wordpress-db"
  allocated_storage   = 10
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.4.5"
  instance_class      = "db.t3.micro"
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
  multi_az            = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name

  #   backup_retention_period = 7
  #   backup_window          = "03:00-04:00"
}