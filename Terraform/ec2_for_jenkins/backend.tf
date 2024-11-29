
terraform {
  backend "s3" {
    bucket         = "myteraformstate"
    key            = "EC2_for_jenkins/terraform.tfstate"
    region         = "us-east-1"
  }
}