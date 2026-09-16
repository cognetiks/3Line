variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "dr"
}

variable "project_name" {
  type    = string
  default = "3line"
}

variable "azs" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.0.0/24", "10.2.1.0/24"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.10.0/24", "10.2.11.0/24"]
}

variable "private_db_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.20.0/24", "10.2.21.0/24"]
}

# Name of the prod ECR repository, replicated into var.aws_region by the prod environment.
variable "ecr_repository_name" {
  type    = string
  default = "3line-prod"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "container_port" {
  type    = number
  default = 80
}

# Warm-standby sizing by default; scale up (see prod values) during an actual failover.
variable "ecs_cpu" {
  type    = number
  default = 512
}

variable "ecs_memory" {
  type    = number
  default = 1024
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "db_instance_class" {
  type    = string
  default = "db.r6g.large"
}

# ARN of the prod RDS instance (module.rds.rds_arn output from the prod environment).
variable "source_db_instance_arn" {
  type = string
}

variable "redis_node_type" {
  type    = string
  default = "cache.r6g.large"
}

variable "redis_num_cache_nodes" {
  type    = number
  default = 1
}

variable "alarm_email" {
  type    = string
  default = null
}
