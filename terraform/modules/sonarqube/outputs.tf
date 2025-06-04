output "sonarqube_instance_id" {
  description = "ID of the SonarQube EC2 instance"
  value       = aws_instance.sonarqube.id
}

output "sonarqube_public_ip" {
  description = "Public IP address of the SonarQube instance"
  value       = aws_instance.sonarqube.public_ip
}


output "sonarqube_security_group_id" {
  description = "ID of the SonarQube security group"
  value       = aws_security_group.sonarqube.id
}

output "sonarqube_db_password_parameter_arn" {
  description = "ARN of the database password parameter in Parameter Store"
  value       = aws_ssm_parameter.sonarqube_db_password.arn
}

# output "sonarqube_ngrok_url" {
#   description = "Ngrok URL for accessing SonarQube"
#   value       = aws_ssm_parameter.sonarqube_ngrok_url.value
# } 