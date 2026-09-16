output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_arn" {
  value = module.rds.arn
}

output "redis_endpoint" {
  value = module.elasticache.primary_endpoint_address
}
