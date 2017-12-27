resource "aws_ecs_cluster" "worker" {
  name = "${var.name}-worker"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/files/task-definition.json.tpl")}"

  vars {
    cluster        = "${var.name}"
    name           = "${var.name}-worker"
    image          = "filepreviews/filepreviews:${var.filepreviews_version}"
    container_name = "filepreviews-worker"
    license_url    = "${var.filepreviews_license_url}"
    database_url   = "${var.database_url}"
    secret_key     = "${var.secret_key}"
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                = "${var.name}-worker"
  container_definitions = "${data.template_file.task_definition.rendered}"
  task_role_arn         = "${var.task_role_arn}"
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = "${aws_ecs_cluster.worker.id}"
  task_definition = "${aws_ecs_task_definition.worker.arn}"
  desired_count   = 1

  # TODO Change this back to 50 or 100
  deployment_minimum_healthy_percent = 0
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/files/cloud-config.yml.tpl")}"

  vars {
    name = "${var.name}-worker"
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix = "${var.name}-worker-"

  image_id             = "${var.filepreviews_ami_id}"
  instance_type        = "t2.medium"
  iam_instance_profile = "${var.iam_instance_profile}"
  key_name             = "aws-filepreviews"
  security_groups      = ["${var.cluster_security_group}"]
  user_data            = "${data.template_file.cloud_config.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 25
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name = "${var.name}-worker - ${aws_launch_configuration.main.name}"

  vpc_zone_identifier  = ["${var.subnet_ids}"]
  launch_configuration = "${aws_launch_configuration.main.id}"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  termination_policies = ["OldestLaunchConfiguration", "Default"]

  tag {
    key                 = "Name"
    value               = "${var.name}-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
