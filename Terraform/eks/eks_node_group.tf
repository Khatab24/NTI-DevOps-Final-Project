resource "aws_key_pair" "ubuntu_key" {
  key_name   = "ubuntu-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id] 
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"] 

  remote_access {
    ec2_ssh_key = aws_key_pair.ubuntu_key.key_name
  }

  depends_on = [
    aws_security_group.sg,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "eks_node_group"
  }
}
