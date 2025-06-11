output "sonarqube_instance_profile_name" {
  description = "Name of the SonarQube instance profile"
  value       = aws_iam_instance_profile.sonarqube_instance_profile.name
}

output "sonarqube_instance_role_arn" {
  description = "ARN of the SonarQube instance role"
  value       = aws_iam_role.sonarqube_instance_role.arn
}

output "sonarqube_route53_role_arn" {
  description = "ARN of the SonarQube Route53 role"
  value       = aws_iam_role.sonarqube_route53.arn
}

output "lambda_route53_role_arn" {
  description = "ARN of the Lambda Route53 role"
  value       = aws_iam_role.lambda_route53.arn
} 