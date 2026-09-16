variable "bucket_name" {
  type = string
}

variable "noncurrent_version_expiration_days" {
  type    = number
  default = 365
}

variable "transition_to_ia_days" {
  type    = number
  default = 30
}

variable "transition_to_glacier_days" {
  type    = number
  default = 90
}

variable "tags" {
  type    = map(string)
  default = {}
}
