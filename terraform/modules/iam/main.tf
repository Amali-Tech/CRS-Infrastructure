# IAM Roles and Policies Module

# SonarQube EC2 Instance Role
resource "aws_iam_role" "sonarqube_instance_role" {
  name = "${var.project_name}-${var.environment}-sonarqube-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-sonarqube-instance-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# SonarQube EC2 Instance Profile
resource "aws_iam_instance_profile" "sonarqube_instance_profile" {
  name = "${var.project_name}-${var.environment}-sonarqube-instance-profile"
  role = aws_iam_role.sonarqube_instance_role.name
}

# SonarQube EC2 Instance Policy
resource "aws_iam_role_policy" "sonarqube_instance_policy" {
  name = "${var.project_name}-${var.environment}-sonarqube-instance-policy"
  role = aws_iam_role.sonarqube_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Systems Manager Session Manager Policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.sonarqube_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Systems Manager Session Manager Policy
resource "aws_iam_role_policy_attachment" "ssm_session_policy" {
  role       = aws_iam_role.sonarqube_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# IAM Policy for Parameter Store access
resource "aws_iam_role_policy" "parameter_store" {
  name = "${var.project_name}-${var.environment}-sonarqube-parameter-store"
  role = aws_iam_role.sonarqube_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/sonarqube/*"
        ]
      }
    ]
  })
}

# IAM role for Route 53 updates
resource "aws_iam_role" "sonarqube_route53" {
  name = "${var.project_name}-${var.environment}-sonarqube-route53"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-sonarqube-route53-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM policy for Route 53 updates
resource "aws_iam_role_policy" "sonarqube_route53" {
  name = "${var.project_name}-${var.environment}-sonarqube-route53-policy"
  role = aws_iam_role.sonarqube_route53.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      }
    ]
  })
}

# IAM instance profile for Route 53
resource "aws_iam_instance_profile" "sonarqube_route53" {
  name = "${var.project_name}-${var.environment}-sonarqube-route53-profile"
  role = aws_iam_role.sonarqube_route53.name
}

# Data sources for region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM role for Lambda Route53 updates
resource "aws_iam_role" "lambda_route53" {
  name = "${var.project_name}-${var.environment}-lambda-route53-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-route53-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM policy for Lambda Route53 updates
resource "aws_iam_role_policy" "lambda_route53" {
  name = "${var.project_name}-${var.environment}-lambda-route53-policy"
  role = aws_iam_role.lambda_route53.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
} 