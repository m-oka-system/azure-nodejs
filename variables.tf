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

variable "vm_size" {
  type = string
}

variable "vm_admin_username" {
  type = string
}
