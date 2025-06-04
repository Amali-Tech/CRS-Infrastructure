output "vpc_id" {
  description = "ID of the VPC"
  value       = module.shared.vpc_id
}

# output "frontend_bucket_name" {
#   description = "Name of the frontend S3 bucket"
#   value       = module.shared.frontend_bucket_name
# }

# output "cloudfront_distribution_domain_name" {
#   description = "Domain name of the CloudFront distribution"
#   value       = module.shared.cloudfront_distribution_domain_name
# }

output "sonarqube_instance_id" {
  description = "ID of the SonarQube EC2 instance"
  value       = module.sonarqube.sonarqube_instance_id
} 