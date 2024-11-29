provider "aws" {
  region = "us-east-1" 
}

data "aws_instance" "jenkins" {
  instance_id = var.jenkins_instance_id
}

resource "aws_backup_plan" "jenkins_backup_plan" {
  name = "jenkins-daily-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.jenkins_backup_vault.name
    schedule          = "cron(0 12 * * ? *)" # Daily at 12 PM UTC
    lifecycle {
      delete_after = 30 
    }
  }
}

resource "aws_backup_vault" "jenkins_backup_vault" {
  name = "jenkins-backup-vault"
}

resource "aws_backup_selection" "jenkins_backup_selection" {
  name          = "jenkins-backup-selection"
  iam_role_arn  = aws_iam_role.backup_role.arn
  plan_id = aws_backup_plan.jenkins_backup_plan.id

  resources = [
    data.aws_instance.jenkins.arn
  ]
}

resource "aws_iam_role" "backup_role" {
  name = "BackupServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
