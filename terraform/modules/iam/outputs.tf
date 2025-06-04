output "sonarqube_instance_profile_name" {
  description = "Name of the SonarQube EC2 instance profile"
  value       = aws_iam_instance_profile.sonarqube_instance_profile.name
}
 
output "sonarqube_route53_instance_profile_name" {
  description = "Name of the SonarQube Route 53 instance profile"
  value       = aws_iam_instance_profile.sonarqube_route53.name
} 