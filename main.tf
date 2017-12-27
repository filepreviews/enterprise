provider "aws" {
  version = "~> 1.6"

  profile = "${var.profile}"
  region  = "${var.region}"
}

locals {
  filepreviews_ami_id  = "ami-b7591acd"
  filepreviews_version = "1.2.0"
}

resource "random_string" "secret_key" {
  length  = 50
  special = true
}

module "vpc" {
  source = "./modules/vpc"

  name               = "${var.name}"
  cidr               = "${var.cidr}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${var.availability_zones}"
}

module "security_groups" {
  source = "./modules/security-groups"

  name   = "${var.name}"
  cidr   = "${var.cidr}"
  vpc_id = "${module.vpc.id}"
}

module "iam_role" {
  source = "./modules/iam-role"

  name = "${var.name}"
}

module "s3" {
  source = "./modules/s3"

  name                      = "${var.name}"
  filepreviews_license_path = "${var.filepreviews_license_path}"
}

module "sqs" {
  source = "./modules/sqs"

  name = "${var.name}"
}

module "database" {
  source = "./modules/database"

  name            = "${var.name}-web"
  vpc_id          = "${module.vpc.id}"
  subnet_ids      = ["${module.vpc.internal_subnets}"]
  security_groups = ["${module.security_groups.database}"]
  username        = "filepreviews"
  database        = "filepreviews"
}

module "web" {
  source = "./modules/web"

  name                   = "${var.name}"
  vpc_id                 = "${module.vpc.id}"
  internal_subnet_ids    = ["${module.vpc.internal_subnets}"]
  external_subnet_ids    = ["${module.vpc.external_subnets}"]
  iam_instance_profile   = "${module.iam_role.ecs_profile}"
  iam_role               = "${module.iam_role.ecs_arn}"
  task_role_arn          = "${module.iam_role.ecs_task_role_arn}"
  alb_security_group     = "${module.security_groups.web_lb}"
  cluster_security_group = "${module.security_groups.web_cluster}"

  filepreviews_ami_id      = "${local.filepreviews_ami_id}"
  filepreviews_version     = "${local.filepreviews_version}"
  filepreviews_license_url = "${module.s3.license_url}"
  database_url             = "${module.database.url}"
  secret_key               = "${random_string.secret_key.result}"
}

module "worker" {
  source = "./modules/worker"

  name                   = "${var.name}"
  vpc_id                 = "${module.vpc.id}"
  subnet_ids             = ["${module.vpc.internal_subnets}"]
  iam_instance_profile   = "${module.iam_role.ecs_profile}"
  task_role_arn          = "${module.iam_role.ecs_task_role_arn}"
  cluster_security_group = "${module.security_groups.worker_cluster}"

  filepreviews_ami_id      = "${local.filepreviews_ami_id}"
  filepreviews_version     = "${local.filepreviews_version}"
  filepreviews_license_url = "${module.s3.license_url}"
  database_url             = "${module.database.url}"
  secret_key               = "${random_string.secret_key.result}"
}

module "bastion" {
  source = "./modules/bastion"

  name                = "${var.name}"
  filepreviews_ami_id = "${local.filepreviews_ami_id}"
  security_group      = "${module.security_groups.bastion_ssh}"
  subnet_id           = "${element(module.vpc.external_subnets, 0)}"
  enabled             = "false"
}

output "web_lb_address" {
  value = "${module.web.web_lb_address}"
}

output "bastion_ip" {
  value = "${module.bastion.external_ip}"
}
