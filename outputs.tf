output "redis_primary_endpoint" {
  description = "Primary endpoint address for the Redis replication group"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Configuration endpoint for readers (if applicable)"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
  sensitive   = false
}

output "redis_auth_secret_arn" {
  description = "Secrets Manager ARN storing the Redis AUTH token"
  value       = aws_secretsmanager_secret.redis_auth.arn
}

output "redis_auth_secret_version_id" {
  description = "Secrets Manager secret version id (you can fetch value via AWS SDK)"
  value       = aws_secretsmanager_secret_version.redis_auth_version.version_id
  sensitive   = true
}

output "nonce_hmac_secret_arn" {
  description = "Secrets Manager ARN storing the NONCE HMAC secret"
  value       = aws_secretsmanager_secret.nonce_hmac.arn
}

output "nonce_hmac_secret_version_id" {
  description = "Secrets Manager secret version id for the NONCE HMAC secret"
  value       = aws_secretsmanager_secret_version.nonce_hmac_version.version_id
  sensitive   = true
}
