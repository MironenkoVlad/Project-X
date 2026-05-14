resource "aws_db_subnet_group" "main" {
  name       = "routebox-${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "routebox-${var.environment}-db-subnets"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "routebox-${var.environment}-postgres14"
  family = "postgres14"

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "idle_in_transaction_session_timeout"
    value = "600000"
  }

  parameter {
    name  = "statement_timeout"
    value = "60000"
  }

  tags = {
    Name = "routebox-${var.environment}-postgres14"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "routebox-${var.environment}"
  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "routebox"
  username = var.db_master_username
  password = var.db_master_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  multi_az               = var.multi_az
  publicly_accessible    = false
  backup_retention_period = var.backup_retention_days
  backup_window          = "06:00-06:30"
  maintenance_window     = "sun:07:00-sun:07:30"

  auto_minor_version_upgrade = false
  copy_tags_to_snapshot      = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : "routebox-${var.environment}-final"

  tags = {
    Name = "routebox-${var.environment}"
  }
}
