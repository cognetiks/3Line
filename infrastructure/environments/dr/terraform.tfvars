aws_region              = "us-west-2"
environment             = "dr"
# Set to the rds_arn output from the prod environment after it has been applied.
source_db_instance_arn  = "arn:aws:rds:us-east-1:123456789012:db:3line-prod-db"
