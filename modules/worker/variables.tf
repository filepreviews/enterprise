variable "name" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "iam_instance_profile" {}
variable "task_role_arn" {}
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
