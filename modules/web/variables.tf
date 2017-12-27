variable "name" {}

variable "vpc_id" {}

variable "internal_subnet_ids" {
  type = "list"
}

variable "external_subnet_ids" {
  type = "list"
}

variable "iam_instance_profile" {}
variable "iam_role" {}
variable "task_role_arn" {}
variable "alb_security_group" {}
variable "cluster_security_group" {}

variable "filepreviews_ami_id" {
  description = "AMI ID for FilePreviews instances"
}

variable "filepreviews_version" {
  description = "FilePreviews version"
}

variable "filepreviews_license_url" {}

variable "database_url" {}
variable "secret_key" {}
