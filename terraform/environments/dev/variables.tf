variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "sonarqube_db_password" {
  description = "Password for SonarQube database"
  type        = string
  sensitive   = true
}

# variable "ngrok_auth_token" {
#   description = "Auth token for ngrok"
#   type        = string
#   sensitive   = true
# }

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
} 