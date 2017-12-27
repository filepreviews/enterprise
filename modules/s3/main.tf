locals {
  license_shasum = "${md5(file("${var.filepreviews_license_path}"))}"
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.name}"
  acl           = "public-read"
}

resource "aws_s3_bucket_object" "license" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "${local.license_shasum}/license.fpe"
  source = "${var.filepreviews_license_path}"
  etag   = "${local.license_shasum}"
  acl    = "public-read"
}

output "license_url" {
  value = "https://${aws_s3_bucket.bucket.bucket_domain_name}/${aws_s3_bucket_object.license.id}"
}
