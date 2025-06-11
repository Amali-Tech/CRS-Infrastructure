# Shared Infrastructure
module "shared" {
  source = "../../modules/shared"

  project_name        = var.project_name
  environment         = var.environment
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# IAM Roles and Policies
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
  aws_account_id = var.aws_account_id
  route53_zone_id = var.route53_zone_id
  sonarqube_instance_id = module.sonarqube.instance_id
}

# SonarQube
module "sonarqube" {
  source = "../../modules/sonarqube"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id             = module.shared.vpc_id
  vpc_cidr           = module.shared.vpc_cidr
  private_subnet_ids = module.shared.private_subnet_ids
  public_subnet_ids  = module.shared.public_subnet_ids
  db_password        = var.sonarqube_db_password
  # ngrok_auth_token   = var.ngrok_auth_token
  route53_zone_id    = var.route53_zone_id
  domain_name        = var.domain_name
  iam_instance_profile = module.iam.sonarqube_instance_profile_name
  lambda_route53_role_arn = module.iam.lambda_route53_role_arn
} 