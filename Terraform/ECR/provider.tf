provider "aws" {
  region  = var.aws_region
  profile = "default"
}


terraform {
  backend "s3" {
    bucket         = "myteraformstate"
    key            = "ECR/terraform.tfstate"
    region         = "us-east-1"
  }
}
