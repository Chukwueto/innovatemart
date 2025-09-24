terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


terraform {
  backend "s3" {
    bucket       = "practice-eks-install-bucket"
    key          = "dev/terraform-state-file"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true #S3 native locking
  }
}

locals {
  private_subnet_cidr = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] #CIDR blocks for private subnets
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]  #List all the availiability zones to distribute subnets
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  #CIDR blocks for public subnets
  private_subnet_cidr = local.private_subnet_cidr #CIDR blocks for private subnets
}


module "eks" {
  source = "./modules/eks"

  region           = "us-east-1"           #AWS region
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  eks_cluster_name = "my_eks_cluster_name" #Name of the EKS Cluster to create
  private_subnet_cidr = local.private_subnet_cidr #CIDR blocks for private subnets
  cluster_version  = 1.33  #Kubernetes version for the EKS control plane
  
  node_groups = {
    general = {
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 1
      }
    }
  }    
}