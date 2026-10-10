resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_security_group" "this" {
  name        = "${var.name}-rds-sg"
  description = "Allow DB traffic from ECS tasks only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from the allowed security groups"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}

resource "aws_db_instance" "this" {
  #checkov:skip=CKV_AWS_157:Multi AZ is set per environment and is enabled in prod
  #checkov:skip=CKV_AWS_133:Backup retention is set per environment and is 30 days in prod and replicas inherit it
  #checkov:skip=CKV_AWS_293:Deletion protection is controlled per environment through a variable
  #checkov:skip=CKV_AWS_353:Performance Insights is not required for this workload
  identifier     = "${var.name}-db"
  instance_class = var.instance_class

  # Replica settings are inherited from the source when is_read_replica = true.
  engine                      = var.is_read_replica ? null : var.engine
  engine_version              = var.is_read_replica ? null : var.engine_version
  allocated_storage           = var.is_read_replica ? null : var.allocated_storage
  db_name                     = var.is_read_replica ? null : var.db_name
  username                    = var.is_read_replica ? null : var.username
  manage_master_user_password = var.is_read_replica ? null : true
  replicate_source_db         = var.is_read_replica ? var.source_db_instance_arn : null

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  multi_az                  = var.multi_az
  storage_encrypted         = true
  kms_key_id                = var.kms_key_id
  backup_retention_period   = var.is_read_replica ? null : var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"

  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  parameter_group_name            = aws_db_parameter_group.this.name
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.monitoring.arn

  tags = var.tags
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-pg"
  family = "postgres${split(".", var.engine_version)[0]}"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = var.tags
}

resource "aws_iam_role" "monitoring" {
  name = "${var.name}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
