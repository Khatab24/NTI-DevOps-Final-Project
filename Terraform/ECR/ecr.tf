resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = var.ecr_repository_name 
  tags = {
    Name        = "MyECRRepository"
}
}
