
terraform {
  backend "s3" {
    bucket         = "myteraformstate"
    key            = "Daily_Snapshot/terraform.tfstate"
    region         = "us-east-1"
  }
}