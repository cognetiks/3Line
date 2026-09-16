variable "name" {
  type = string
}

variable "schedule" {
  type    = string
  default = "cron(0 5 * * ? *)"
}

variable "retention_days" {
  type    = number
  default = 35
}

# Resources selected explicitly by ARN (e.g. RDS instances).
variable "resource_arns" {
  type    = list(string)
  default = []
}

# Resources selected by tag, used to catch EBS volumes backing ECS/EC2 workloads.
variable "selection_tag_key" {
  type    = string
  default = "Backup"
}

variable "selection_tag_value" {
  type    = string
  default = "true"
}

variable "tags" {
  type    = map(string)
  default = {}
}
