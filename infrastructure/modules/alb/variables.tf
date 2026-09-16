variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "container_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "certificate_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
