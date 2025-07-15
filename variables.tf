
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "password123"
}

variable "db_name" {
  description = "Database name"
  type        = string
  sensitive   = true
  default     = "wordpress"
}

variable "ssh_pub_key" {
  description = "Public SSH key"
  default     = "~/.ssh/aws_bastion_key.pub"
}
