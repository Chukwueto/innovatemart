provider "aws" {
  region = var.aws_region
}


resource "aws_iam_user" "developer" {
  name = var.iam_user_name
}


resource "aws_iam_policy" "developer_eks" {
  name = "AmazonEKSDeveloperPolicy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.developer_eks.arn
}


# IAM user console 
resource "aws_iam_user" "developer" {
  name = "developer"
}

# Temporary password for AWS Console login
resource "aws_iam_user_login_profile" "developer_console" {
  user                    = aws_iam_user.developer.name
  password                = "TempPassword123!"
  password_reset_required = true
}


# IAM Access Key
resource "aws_iam_access_key" "developer_key" {
  user = aws_iam_user.developer.name
}

# Get existing EKS cluster info
data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

#  Map IAM user into Kubernetes RBAC via Access Entry
resource "aws_eks_access_entry" "developer" {
  cluster_name      = data.aws_eks_cluster.eks.name
  principal_arn     = aws_iam_user.developer.arn
  kubernetes_groups = [var.k8s_group]
}
