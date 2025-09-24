variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "iam_user_name" {
  description = "IAM username to create"
  type        = string
  default     = "developer"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "k8s_group" {
  description = "Kubernetes group to map the IAM user to"
  type        = string
  default     = "my-viewer"
}
