provider "aws" {
  version = "~> 1.20"

  profile = "${var.aws_profile}"
  region  = "us-east-1"
}

locals {
  filepreviews_ami_id = "ami-4cb4ff33"
  domain_name         = "${var.domain_name != "" ? var.domain_name : module.web.web_lb_address}"
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

module "database" {
  source = "./modules/database"

  name            = "${var.name}"
  vpc_id          = "${module.vpc.id}"
  subnet_ids      = ["${module.vpc.internal_subnets}"]
  security_groups = ["${module.security_groups.database}"]
  username        = "filepreviews"
  database        = "filepreviews"
}

module "redis" {
  source = "./modules/redis"

  name            = "${var.name}"
  vpc_id          = "${module.vpc.id}"
  subnet_ids      = ["${module.vpc.internal_subnets}"]
  security_groups = ["${module.security_groups.redis}"]
}

module "web" {
  source = "./modules/web"

  name                   = "${var.name}"
  vpc_id                 = "${module.vpc.id}"
  internal_subnet_ids    = ["${module.vpc.internal_subnets}"]
  external_subnet_ids    = ["${module.vpc.external_subnets}"]
  iam_instance_profile   = "${module.iam_role.instance_profile}"
  alb_security_group     = "${module.security_groups.web_lb}"
  cluster_security_group = "${module.security_groups.web_cluster}"

  filepreviews_ami_id      = "${local.filepreviews_ami_id}"
  filepreviews_license_key = "${var.license_key}"
  database_url             = "${module.database.url}"
  redis_url                = "${module.redis.url}"
  secret_key               = "${random_string.secret_key.result}"
  domain_name              = "${local.domain_name}"
}

module "worker" {
  source = "./modules/worker"

  name                   = "${var.name}"
  vpc_id                 = "${module.vpc.id}"
  subnet_ids             = ["${module.vpc.internal_subnets}"]
  iam_instance_profile   = "${module.iam_role.instance_profile}"
  cluster_security_group = "${module.security_groups.worker_cluster}"

  filepreviews_ami_id      = "${local.filepreviews_ami_id}"
  filepreviews_license_key = "${var.license_key}"
  database_url             = "${module.database.url}"
  redis_url                = "${module.redis.url}"
  secret_key               = "${random_string.secret_key.result}"
  domain_name              = "${local.domain_name}"
}

module "bastion" {
  source = "./modules/bastion"

  name                = "${var.name}"
  filepreviews_ami_id = "${local.filepreviews_ami_id}"
  security_group      = "${module.security_groups.bastion_ssh}"
  subnet_id           = "${element(module.vpc.external_subnets, 0)}"
  enabled             = "${var.enable_bastion}"
}

output "web_lb_address" {
  value = "${module.web.web_lb_address}"
}
