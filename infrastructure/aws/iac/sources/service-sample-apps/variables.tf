variable "engine" {
  type        = string
  description = "RDS Engine"
  default     = "aurora-postgresql"
}

variable "engine_version" {
  type        = string
  description = "RDS Engine Version"
  default     = "14.5"
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "postgres14"
}

variable "deletion_protection" {
  description = "Protection from deletion"
  type        = bool
  default     = false
}

variable "db_port" {
  description = "DB Port"
  type        = number
  default     = 5432
}

variable "instance_class" {
  description = "Database Instance Class"
  type        = string
  default     = "db.t3.medium"
}

variable "database_name" {
  type        = string
  description = "The database name."
  default     = "sample-apps"
}

variable "master_username" {
  type        = string
  description = "The username for database."
  default     = "master_user"
  validation {
    condition = can(regex("^[a-z0-9_]{3,20}$", var.master_username))

    error_message = "Invalid format of the input. The values of `database_name` expected to be of the following format 'abc_abc'."
  }
}

variable "database_subnets" {
  type        = list(string)
  description = "The list of subnets"

  validation {
    condition = (
    length(var.database_subnets) > 0
    )

    error_message = "Database Subnets must not be empty."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC Identifier"
}

variable "vpc_sg_id" {
  type        = string
  description = "VPC's Security Group"
}

variable "eks_sg_id" {
  type        = string
  description = "EKS Security Group"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Database Subnet Group Name"
}

variable "is_public" {
  type        = bool
  description = "If true, instance will have public IP"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "The default map of tags"
}