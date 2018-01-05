data "template_file" "cloud_config" {
  template = "${file("${path.module}/files/cloud-config.yml.tpl")}"

  vars {
    queue_name_prefix    = "${var.name}-"
    filepreviews_version = "${var.filepreviews_version}"
    license_key          = "${var.filepreviews_license_key}"
    database_url         = "${var.database_url}"
    secret_key           = "${var.secret_key}"
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix = "${var.name}-worker-"

  image_id             = "${var.filepreviews_ami_id}"
  instance_type        = "c5.large"
  iam_instance_profile = "${var.iam_instance_profile}"
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
  termination_policies = ["OldestLaunchConfiguration"]

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
