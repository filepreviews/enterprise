resource "random_string" "password" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.name}"
  description = "RDS subnet group"
  subnet_ids  = ["${var.subnet_ids}"]
}

resource "aws_db_instance" "main" {
  identifier = "${var.name}"

  # Database
  engine         = "postgres"
  engine_version = "9.6.3"
  username       = "${var.username}"
  password       = "${random_string.password.result}"
  name           = "${var.database}"

  # Hardware
  instance_class    = "db.t2.micro"
  storage_type      = "gp2"
  allocated_storage = 10

  # Network / security
  db_subnet_group_name   = "${aws_db_subnet_group.main.id}"
  vpc_security_group_ids = ["${var.security_groups}"]

  # Backup / Maintenance
  skip_final_snapshot = true
}

# output "addr" {
#   value = "${aws_db_instance.main.engine}://${aws_db_instance.main.username}:${aws_db_instance.main.password}@${aws_db_instance.main.endpoint}"
# }

output "url" {
  value = "${aws_db_instance.main.engine}://${aws_db_instance.main.username}:${aws_db_instance.main.password}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.name}"
}