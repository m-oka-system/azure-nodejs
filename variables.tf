# Input Variables
variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "allowed_cidr" {
  type = list(any)
}
