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
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-db"
  instance_class = var.instance_class

  # Replica settings are inherited from the source when is_read_replica = true.
  engine                       = var.is_read_replica ? null : var.engine
  engine_version               = var.is_read_replica ? null : var.engine_version
  allocated_storage            = var.is_read_replica ? null : var.allocated_storage
  db_name                      = var.is_read_replica ? null : var.db_name
  username                     = var.is_read_replica ? null : var.username
  manage_master_user_password  = var.is_read_replica ? null : true
  replicate_source_db          = var.is_read_replica ? var.source_db_instance_arn : null

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  multi_az                = var.multi_az
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  backup_retention_period = var.is_read_replica ? null : var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"

  copy_tags_to_snapshot = true

  tags = var.tags
}
