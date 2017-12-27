resource "aws_instance" "bastion" {
  count                  = "${var.enabled == "true" ? 1 : 0}"
  ami                    = "${var.filepreviews_ami_id}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.security_group}"]
  instance_type          = "t2.micro"
  key_name               = "aws-filepreviews"

  tags {
    Name = "${var.name}-bastion"
  }
}

output "external_ip" {
  value = "${element(concat(aws_instance.bastion.*.public_ip, list("")), 0)}"
}
