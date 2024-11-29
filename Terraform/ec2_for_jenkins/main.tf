provider "aws" {
  region = var.aws_region
}
data "aws_vpc" "default" {
  default = true
}
data "aws_security_group" "existing_sg" {
  id = var.security_group_id
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"  
  public_key = file(var.ssh_public_key_path) 
}


resource "aws_iam_role" "jenkins_ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_access_policy" {
  name        = "Jenkins-EKS-Access-Policy"
  description = "Policy for EC2 to access EKS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action: [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action: [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access_attachment" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = aws_iam_policy.eks_access_policy.arn
}




resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  tags = {
    Name = "Jenkins-EC2"
  }
    iam_instance_profile = aws_iam_instance_profile.jenkins_ec2_instance_profile.name
}



resource "aws_iam_instance_profile" "jenkins_ec2_instance_profile" {
  name = "jenkins-ec2-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = var.security_group_id
  cidr_blocks       = ["0.0.0.0/0"] 
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = var.security_group_id
  cidr_blocks       = ["0.0.0.0/0"] 
}

