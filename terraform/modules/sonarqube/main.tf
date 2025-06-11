# Security Group for SonarQube
resource "aws_security_group" "sonarqube" {
  name        = "${var.project_name}-${var.environment}-sonarqube-sg"
  description = "Security group for SonarQube instance"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SonarQube traffic
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-sonarqube-sg"
  }
}

# Get subnet details to get the availability zone
data "aws_subnet" "selected" {
  id = var.public_subnet_ids[0]
}

# EBS Volume for SonarQube Data
resource "aws_ebs_volume" "sonarqube_data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size             = 20
  type             = "gp3"

  tags = {
    Name        = "${var.project_name}-${var.environment}-sonarqube-data"
    Environment = var.environment
    Project     = var.project_name
  }
}

# EBS Volume for PostgreSQL Data
resource "aws_ebs_volume" "postgresql_data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size             = 20
  type             = "gp2"

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgresql-data"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Parameter Store entries for database credentials and ngrok URL
resource "aws_ssm_parameter" "sonarqube_db_password" {
  name        = "/${var.project_name}/${var.environment}/sonarqube/db/password"
  description = "SonarQube database password"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "sonarqube_db_user" {
  name        = "/${var.project_name}/${var.environment}/sonarqube/db/user"
  description = "SonarQube database user"
  type        = "String"
  value       = var.db_username

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# EC2 Instance for SonarQube
resource "aws_instance" "sonarqube" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  iam_instance_profile   = var.iam_instance_profile

  # Enable auto-assign public IP
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-sonarqube"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [
    aws_ssm_parameter.sonarqube_db_password,
    aws_ssm_parameter.sonarqube_db_user
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      associate_public_ip_address
    ]
  }
}

# Attach EBS Volumes to EC2 Instance
resource "aws_volume_attachment" "sonarqube_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.sonarqube_data.id
  instance_id = aws_instance.sonarqube.id

  depends_on = [
    aws_instance.sonarqube,
    aws_ebs_volume.sonarqube_data
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "postgresql_data" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.postgresql_data.id
  instance_id = aws_instance.sonarqube.id

  depends_on = [
    aws_instance.sonarqube,
    aws_ebs_volume.postgresql_data
  ]

  lifecycle {
    prevent_destroy = true
  }
}

# Create Route 53 record for SonarQube
resource "aws_route53_record" "sonarqube" {
  zone_id = var.route53_zone_id
  name    = "sonar.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.sonarqube.public_ip]

  depends_on = [
    aws_instance.sonarqube
  ]

  lifecycle {
    ignore_changes = [
      records
    ]
  }
}

# Data sources for region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Lambda function to update Route53 record
resource "aws_lambda_function" "update_route53" {
  filename         = "${path.module}/lambda/update_route53.zip"
  function_name    = "${var.project_name}-${var.environment}-update-route53"
  role            = var.lambda_route53_role_arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30

  environment {
    variables = {
      INSTANCE_ID    = aws_instance.sonarqube.id
      HOSTED_ZONE_ID = var.route53_zone_id
      DOMAIN_NAME    = var.domain_name
    }
  }
}

# EventBridge rule to trigger Lambda after instance start
resource "aws_cloudwatch_event_rule" "instance_running" {
  name        = "${var.project_name}-${var.environment}-instance-running"
  description = "Trigger when SonarQube instance is running"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      "instance-id" = [aws_instance.sonarqube.id]
      state         = ["running"]
    }
  })
}

# EventBridge target for Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.instance_running.name
  target_id = "UpdateRoute53"
  arn       = aws_lambda_function.update_route53.arn
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_route53.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_running.arn
}

