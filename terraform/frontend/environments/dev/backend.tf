terraform {


   backend "s3" {
    bucket       = "crs-terraform-state-2025"  # Updated bucket name
    key          = "frontend/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true  # Enable S3 native lockingg
  }
} 