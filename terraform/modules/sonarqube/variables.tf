variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the SonarQube EC2 instance"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS
}

variable "instance_type" {
  description = "Instance type for the SonarQube EC2 instance"
  type        = string
  default     = "t3.medium"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "sonarqube"
}

variable "db_password" {
  description = "Password for the SonarQube database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "sonarqube"
}

variable "ngrok_auth_token" {
  description = "Auth token for ngrok"
  type        = string
  sensitive   = true
  default     = ""
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the SonarQube EC2 instance"
  type        = string
} 