output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_repository_name" {
  value = module.ecr.repository_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

# Feed this into the dr environment's source_db_instance_arn variable to build the cross-region read replica.
output "rds_arn" {
  value = module.rds.arn
}

output "redis_endpoint" {
  value = module.elasticache.primary_endpoint_address
}
