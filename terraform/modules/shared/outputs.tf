output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# output "frontend_bucket_name" {
#   description = "Name of the frontend S3 bucket"
#   value       = aws_s3_bucket.frontend.bucket
# }

# output "cloudfront_distribution_domain_name" {
#   description = "Domain name of the CloudFront distribution"
#   value       = aws_cloudfront_distribution.frontend.domain_name
# }

# output "cloudfront_distribution_id" {
#   description = "ID of the CloudFront distribution"
#   value       = aws_cloudfront_distribution.frontend.id
# } 