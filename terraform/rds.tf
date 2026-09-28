resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.Subnet_PRV_RDS.id, aws_subnet.Subnet_PRV_RDS2.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "app_db" {
  identifier = "app-database"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  backup_retention_period = 7
  deletion_protection     = var.enable_deletion_protection
  skip_final_snapshot     = true

  tags = {
    Name = "app-database"
  }
}
