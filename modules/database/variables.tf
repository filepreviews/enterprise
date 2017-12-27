variable "name" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "database" {}

variable "username" {}
