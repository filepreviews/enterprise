variable "alb_security_group" {}
variable "cluster_security_group" {}
variable "database_url" {}

variable "filepreviews_ami_id" {}
variable "filepreviews_license_key" {}
variable "filepreviews_version" {}
variable "iam_instance_profile" {}

variable "name" {}
variable "secret_key" {}
variable "vpc_id" {}

variable "internal_subnet_ids" {
  type = "list"
}

variable "external_subnet_ids" {
  type = "list"
}
