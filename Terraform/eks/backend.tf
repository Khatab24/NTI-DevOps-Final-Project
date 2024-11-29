
terraform {
  backend "s3" {
    bucket = "myteraformstate"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}
