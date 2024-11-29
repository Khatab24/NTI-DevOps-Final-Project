# data "aws_s3_bucket" "alb_logs" {
#   bucket = "myteraformstate"
# }

# resource "aws_s3_bucket_policy" "alb_logs_policy" {
#   bucket = data.aws_s3_bucket.alb_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "AWSLogDeliveryWrite",
#         Effect = "Allow",
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         },
#         Action   = "s3:PutObject",
#         Resource = "${data.aws_s3_bucket.alb_logs.arn}/*"
#       },
#       {
#         Sid       = "AllowELBAccess",
#         Effect    = "Allow",
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         },
#         Action    = "s3:GetBucketAcl",
#         Resource  = data.aws_s3_bucket.alb_logs.arn
#       }
#     ]
#   })
# }

resource "aws_lb" "eks_lb" {
  name               = "eks-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]

  # access_logs {
  #   bucket  = data.aws_s3_bucket.alb_logs.id # Reference the bucket dynamically
  #   enabled = true
  #   prefix  = "alb-logs" # Ensure no leading or trailing slash
  # }
}




resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.eks_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_target_group.arn
  }
}

resource "aws_lb_target_group" "eks_target_group" {
  name     = "eks-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "nodes-target-group"
  }
}


data "aws_instances" "eks_node_instances" {
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.node-grp.node_group_name]
  }
}

resource "aws_lb_target_group_attachment" "node_targets" {
  for_each = toset(data.aws_instances.eks_node_instances.ids)

  target_group_arn = aws_lb_target_group.eks_target_group.arn
  target_id        = each.value
  port             = 80
}
