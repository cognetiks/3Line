locals {
  name          = "${var.project_name}-${var.environment}"
  container_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:${var.image_tag}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

data "aws_caller_identity" "current" {}

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
  container_image    = local.container_image
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

# Cross-region read replica of the prod RDS instance for disaster recovery.
module "rds" {
  source = "../../modules/rds"

  name                    = local.name
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_db_subnet_ids
  allowed_sg_ids          = [module.ecs.service_sg_id]
  instance_class          = var.db_instance_class
  is_read_replica         = true
  source_db_instance_arn  = var.source_db_instance_arn
  deletion_protection     = false
  tags                    = local.tags
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
