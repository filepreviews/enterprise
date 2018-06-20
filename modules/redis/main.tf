resource "random_string" "auth_token" {
  length  = 128
  special = false
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name}"
  subnet_ids = ["${var.subnet_ids}"]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.name}"
  replication_group_description = "Redis replication group"
  engine                        = "redis"
  engine_version                = "3.2.6"
  node_type                     = "cache.t2.medium"
  parameter_group_name          = "default.redis3.2"
  number_cache_clusters         = 1
  port                          = 6379
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  auth_token                    = "${random_string.auth_token.result}"
  subnet_group_name             = "${aws_elasticache_subnet_group.redis.name}"
  security_group_ids            = ["${var.security_groups}"]
  apply_immediately             = true
}

output "url" {
  value = "redis://:${random_string.auth_token.result}@${aws_elasticache_replication_group.redis.primary_endpoint_address}:6379"
}
