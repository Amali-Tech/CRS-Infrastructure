variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "ali-amalitech-state-bucket"
}

variable "state_bucket_region" {
  description = "AWS region for the Terraform state bucket"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "project" {
  description = "The project name (e.g., Frontend)"
  type        = string
}
