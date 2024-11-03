variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "owner" {
  type = string
}

variable "frontend_version" {
  type = string
}

variable "backend_version" {
  type = string
}

variable "allow_cidr" {
  default = "0.0.0.0/0"
}

variable "block_cidr" {
  type = string
}

variable "base_domain" {
  type = string
}