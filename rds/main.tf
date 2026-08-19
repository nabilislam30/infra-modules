# -----------------------------------------------------------------------------
# RDS Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "database" {
  name        = "${var.name}-database"
  description = "Security group for the PostgreSQL RDS instance."
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# PostgreSQL Access from Compute
# -----------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "postgresql_from_compute" {
  security_group_id = aws_security_group.database.id

  description = "Allow PostgreSQL access from compute instances."

  referenced_security_group_id = var.compute_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Database Subnet Group
# -----------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-database"
  subnet_ids = var.database_subnet_ids

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# PostgreSQL RDS Instance
# -----------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier = "${var.name}-postgresql"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_encrypted = true

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false

  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection
  multi_az            = var.multi_az

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.performance_insights_kms_key_id

  iam_database_authentication_enabled = true

  skip_final_snapshot = true

  tags = var.common_tags
}
