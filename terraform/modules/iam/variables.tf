variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  type        = string
  default     = ""
}

variable "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  type        = string
  default     = ""
} 

variable "sonarqube_instance_id" {
  description = "ID of the SonarQube EC2 instance"
  type        = string
} 