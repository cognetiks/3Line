variable "name" {
  type = string
}

variable "ssm_parameter_arns" {
  type    = list(string)
  default = []
}

variable "secrets_manager_arns" {
  type    = list(string)
  default = []
}

variable "kms_key_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
