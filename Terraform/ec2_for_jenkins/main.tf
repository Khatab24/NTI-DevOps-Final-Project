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
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  tags = {
    Name = "Jenkins-EC2"
  }
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

