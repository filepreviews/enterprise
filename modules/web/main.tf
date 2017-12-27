resource "aws_alb" "web" {
  name            = "${var.name}-web-lb"
  security_groups = ["${var.alb_security_group}"]
  subnets         = ["${var.external_subnet_ids}"]
}

resource "aws_alb_target_group" "web" {
  name     = "${var.name}-web-lb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path    = "/auth/login/"
    matcher = "200"
  }
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "web" {
  name = "${var.name}-web"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/files/task-definition.json.tpl")}"

  vars {
    cluster        = "${var.name}"
    name           = "${var.name}-web"
    image          = "filepreviews/filepreviews:${var.filepreviews_version}"
    container_name = "filepreviews-web"
    license_url    = "${var.filepreviews_license_url}"
    database_url   = "${var.database_url}"
    secret_key     = "${var.secret_key}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                = "${var.name}-web"
  container_definitions = "${data.template_file.task_definition.rendered}"
  task_role_arn         = "${var.task_role_arn}"
}

resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = "${aws_ecs_cluster.web.id}"
  task_definition = "${aws_ecs_task_definition.web.arn}"
  desired_count   = 1
  iam_role        = "${var.iam_role}"

  depends_on = [
    "aws_alb_listener.web",
  ]

  # TODO Change this back to 50 or 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    container_name   = "filepreviews-web"
    container_port   = 8000
  }
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/files/cloud-config.yml.tpl")}"

  vars {
    name = "${var.name}-web"
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix = "${var.name}-web-"

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
  name = "${var.name}-web - ${aws_launch_configuration.main.name}"

  vpc_zone_identifier  = ["${var.internal_subnet_ids}"]
  launch_configuration = "${aws_launch_configuration.main.id}"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  termination_policies = ["OldestLaunchConfiguration", "Default"]

  target_group_arns = [
    "${aws_alb_target_group.web.arn}",
  ]

  tag {
    key                 = "Name"
    value               = "${var.name}-web"
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

output "web_lb_address" {
  value = "${aws_alb.web.dns_name}"
}
