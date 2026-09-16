locals {
  name = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                     = local.name
  cidr_block               = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  single_nat_gateway       = false
  tags                     = local.tags
}

module "iam" {
  source = "../../modules/iam"

  name = local.name
  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  name = local.name
  tags = local.tags
}

# Account-level replication so DR (in var.dr_region) can pull the same image digests.
resource "aws_ecr_replication_configuration" "dr" {
  count = var.enable_dr_ecr_replication ? 1 : 0

  replication_configuration {
    rule {
      destination {
        region      = var.dr_region
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

data "aws_caller_identity" "current" {}

module "alb" {
  source = "../../modules/alb"

  name              = local.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
  tags              = local.tags
}

module "waf" {
  source = "../../modules/waf"

  name    = local.name
  alb_arn = module.alb.alb_arn
  tags    = local.tags
}

module "ecs" {
  source = "../../modules/ecs"

  name               = local.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  container_image    = var.container_image
  container_port     = var.container_port
  cpu                = var.ecs_cpu
  memory             = var.ecs_memory
  desired_count      = var.ecs_desired_count
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  tags               = local.tags
}

module "elasticache" {
  source = "../../modules/elasticache"

  name            = local.name
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_app_subnet_ids
  allowed_sg_ids  = [module.ecs.service_sg_id]
  node_type       = var.redis_node_type
  num_cache_nodes = var.redis_num_cache_nodes
  tags            = local.tags
}

module "rds" {
  source = "../../modules/rds"

  name                    = local.name
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_db_subnet_ids
  allowed_sg_ids          = [module.ecs.service_sg_id]
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  tags                    = local.tags
}

module "s3_app_assets" {
  source = "../../modules/s3"

  bucket_name = var.app_assets_bucket_name
  tags        = local.tags
}

module "backup" {
  source = "../../modules/backup"

  name          = local.name
  resource_arns = [module.rds.arn]
  tags          = local.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                    = local.name
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  alb_arn_suffix          = module.alb.alb_arn
  target_group_arn_suffix = module.alb.target_group_arn
  alarm_email             = var.alarm_email
  tags                    = local.tags
}
