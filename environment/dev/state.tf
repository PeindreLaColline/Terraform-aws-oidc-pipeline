terraform {
  required_version = ">= 1.11"

  backend "s3" {
    bucket       = "terraform-aws-oidc-pipeline"
    key          = "terraform-aws-oidc-pipeline/dev/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
    profile      = "dev-profile" 
  }
}