variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
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

variable "db_password" {
  description = "Password for the SonarQube database"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Username for the SonarQube database"
  type        = string
  default     = "sonarqube"
}

variable "ami_id" {
  description = "AMI ID for the SonarQube instance"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS
}

variable "instance_type" {
  description = "Instance type for the SonarQube instance"
  type        = string
  default     = "t3.medium"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the SonarQube instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the SonarQube instance"
  type        = string
}

variable "lambda_route53_role_arn" {
  description = "ARN of the IAM role for the Route53 update Lambda function"
  type        = string
} 