resource "random_password" "redis_auth" {
  length           = 40
  override_characters = "!@#$%&*()-_=+[]{}<>?"
}

resource "random_password" "nonce_hmac" {
  length = 64
  override_characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
}

resource "aws_secretsmanager_secret" "redis_auth" {
  name        = "${var.environment}-redis-auth"
  description = "Redis AUTH token for ${var.environment} ElastiCache cluster"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "redis_auth_version" {
  secret_id     = aws_secretsmanager_secret.redis_auth.id
  secret_string = random_password.redis_auth.result
}

resource "aws_secretsmanager_secret" "nonce_hmac" {
  name        = "${var.environment}-nonce-hmac-secret"
  description = "HMAC secret used for signing single-use nonces for rewards API"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "nonce_hmac_version" {
  secret_id     = aws_secretsmanager_secret.nonce_hmac.id
  secret_string = random_password.nonce_hmac.result
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids
  description = "Subnet group for ${var.environment} Redis"
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.environment}-redis-sg"
  description = "Security group for Redis - restrict to app servers"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? var.allowed_security_group_ids : [var.allowed_cidr]
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = length(var.allowed_security_group_ids) > 0 ? [] : [ingress.value]
      security_groups = length(var.allowed_security_group_ids) > 0 ? [ingress.value] : []
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = coalesce(var.replication_group_id, "${var.environment}-redis-rg")
  replication_group_description = "${var.environment} redis replication group"
  engine                        = "redis"
  engine_version                = var.engine_version
  node_type                     = var.cache_node_type
  number_cache_clusters         = (var.replicas_per_node_group + 1) * var.num_node_groups
  automatic_failover_enabled    = true
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  port                          = var.port
  parameter_group_name          = null
  apply_immediately             = false
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  auth_token                    = random_password.redis_auth.result

  tags = {
    Environment = var.environment
    ManagedBy   = "dev-ops-infra"
  }

  lifecycle {
    ignore_changes = [auth_token] # avoid accidental drift updates
  }
}
