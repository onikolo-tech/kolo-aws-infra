variable "aws_region" {
  description = "AWS region to provision into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Logical environment name (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC id where ElastiCache will be provisioned"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet ids (prefer private subnets)"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Please provide at least two subnet ids in different AZs for Multi-AZ Redis deployments."
  }
}

variable "allowed_cidr" {
  description = "CIDR range allowed to connect (for quick dev). Prefer using allowed_security_group_ids in prod"
  type        = string
  default     = ""
}

variable "allowed_security_group_ids" {
  description = "List of SG IDs allowed to connect to redis (recommended)"
  type        = list(string)
  default     = []
  validation {
    condition = length(var.allowed_security_group_ids) > 0 || var.allowed_cidr != ""
    error_message = "Either provide `allowed_security_group_ids` (recommended) or `allowed_cidr` to allow connections. For production use `allowed_security_group_ids`."
  }
}

variable "cache_node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t4g.small"
}

variable "num_node_groups" {
  description = "Number of node groups (shards). Use 1 for non-clustered Redis"
  type        = number
  default     = 1
}

variable "replicas_per_node_group" {
  description = "Number of replicas per node group (replication factor). Set >=1 for HA"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "replication_group_id" {
  description = "Replication group id (unique)"
  type        = string
  default     = null
}
