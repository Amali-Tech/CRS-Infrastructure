# module "s3" {
#   source = "../../modules/s3"
#   project_name                = var.project_name
#   environment                 = var.environment
#   cloudfront_distribution_arn = module.cloudfront.distribution_arn
# }

# module "cloudfront" {
#   source = "../../modules/cloudfront"
#   project_name                    = var.project_name
#   environment                     = var.environment
#   s3_bucket_regional_domain_name  = module.s3.bucket_regional_domain_name
# }

resource "aws_iam_group" "state_lock_test_group" {
  name = "terraform-state-lock-test-group-dev"
}