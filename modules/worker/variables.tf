variable "cluster_security_group" {}
variable "database_url" {}
variable "filepreviews_ami_id" {}
variable "filepreviews_license_key" {}
variable "filepreviews_version" {}
variable "iam_instance_profile" {}
variable "name" {}
variable "secret_key" {}
variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}
