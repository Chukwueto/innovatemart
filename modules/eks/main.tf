# IAM Role for EKS cluster

resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.eks_cluster_name}-eks-cluster-role"

  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

}



resource "aws_iam_role_policy_attachment" "cluster_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}



resource "aws_eks_cluster" "main-eks-cluster" {
  name = var.eks_cluster_name
  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
  
   depends_on = [
    aws_iam_role_policy_attachment.cluster_Policy
  ]
}




# IAM Role for worker nodes

resource "aws_iam_role" "eks-node-role" {
  name = "${var.eks_cluster_name}-node-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}  


# Attach Required Policies to Worker Node Role

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.eks-node-role.name
}



# Create EKS Managed Node Group

resource "aws_eks_node_group" "eks-worker-node" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main-eks-cluster.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = var.private_subnet_cidr

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy
  ]
}