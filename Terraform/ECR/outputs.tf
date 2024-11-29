output "ecr_repository_name" {
  value       = aws_ecr_repository.my_ecr_repo.name
  description = "The name of the created ECR repository"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.my_ecr_repo.repository_url
  description = "The URL of the created ECR repository"
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.my_ecr_repo.arn
  description = "The ARN of the created ECR repository"
}
