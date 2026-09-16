variable "name" {
  type = string
}

variable "max_image_count" {
  type    = number
  default = 20
}

variable "tags" {
  type    = map(string)
  default = {}
}
