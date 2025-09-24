terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "practice-eks-install-bucket"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

terraform {
  backend "s3" {
    bucket       = "practice-eks-install-bucket"
    key          = "dev/terraform-state-file"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true    #S3 native locking
  }
}
