resource "aws_security_group" "web_lb" {
  name        = "${var.name}-web-lb"
  vpc_id      = "${var.vpc_id}"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web_cluster" {
  name        = "${var.name}-web-cluster"
  vpc_id      = "${var.vpc_id}"
  description = "Allow all inbound traffic"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1

    security_groups = [
      "${aws_security_group.web_lb.id}",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.bastion_ssh.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "worker_cluster" {
  name        = "${var.name}-worker-cluster"
  vpc_id      = "${var.vpc_id}"
  description = "Allow all inbound traffic"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.bastion_ssh.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name}-rds"
  description = "Allows traffic to RDS from other security groups"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"

    security_groups = [
      "${aws_security_group.web_cluster.id}",
      "${aws_security_group.worker_cluster.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_ssh" {
  name        = "${var.name}-bastion-ssh"
  description = "Allows SSH to bastion"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "bastion_ssh" {
  value = "${aws_security_group.bastion_ssh.id}"
}

output "database" {
  value = "${aws_security_group.database.id}"
}

output "web_lb" {
  value = "${aws_security_group.web_lb.id}"
}

output "web_cluster" {
  value = "${aws_security_group.web_cluster.id}"
}

output "worker_cluster" {
  value = "${aws_security_group.worker_cluster.id}"
}
