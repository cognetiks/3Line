variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "cpu_target" {
  type    = number
  default = 60
}

variable "memory_target" {
  type    = number
  default = 70
}
