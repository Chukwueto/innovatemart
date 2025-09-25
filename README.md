# EKS Architecture Overview & Access Guide

## Architecture Overview

This project provisions a production-grade Kubernetes environment on AWS using Terraform. The architecture includes:

- **VPC**: Custom VPC with public and private subnets across three Availability Zones for high availability.
- **EKS Cluster**: Managed Kubernetes control plane deployed in private subnets.
- **Node Groups**: EKS-managed node groups for running workloads.
- **IAM**: 
  - An IAM user (`developer`) with read-only access to the EKS cluster.
  - Custom IAM policies and RBAC mapping for secure access.
- **Networking**: Internet Gateway, NAT Gateway, and route tables for secure and efficient traffic flow.
- **State Management**: Terraform state stored securely in an S3 bucket.

## Accessing the Running Application

1. **Obtain the EKS Cluster Endpoint**
   - After deployment, the EKS cluster endpoint is output as `cluster_endpoint` in Terraform.
   - You can find it in the Terraform output or AWS Console.

2. **Configure `kubectl`**
   - Install [kubectl](https://kubernetes.io/docs/tasks/tools/) and [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
   - Use the provided IAM credentials (see below) to configure AWS CLI:
     ```sh
     aws configure
     # Enter Access Key ID, Secret Access Key, region (us-east-1), and output format
     ```
   - Generate kubeconfig for the cluster:
     ```sh
     aws eks update-kubeconfig --region us-east-1 --name my_eks_cluster_name
     ```

3. **Access the Application**
   - Use `kubectl` to interact with the cluster:
     ```sh
     kubectl get pods --all-namespaces
     ```

## Developer IAM User Credentials & Kubeconfig Instructions

### Credentials

After Terraform apply, the following outputs are available:

- **Access Key ID**: `developer_access_key_id`
- **Secret Access Key**: `developer_secret_access_key`
- **Console Username**: `developer_console_username`
- **Console Temporary Password**: `developer_console_temp_password`

> **Note:** These outputs are marked as sensitive. Retrieve them using:
> ```sh
> terraform output developer_access_key_id
> terraform output developer_secret_access_key
> terraform output developer_console_username
> terraform output developer_console_temp_password
> ```

### AWS Console Access

1. Go to [AWS Console Login](https://console.aws.amazon.com/).
2. Use the username and temporary password provided.
3. Change your password when prompted.

### Kubeconfig Setup for Read-Only Developer

1. **Configure AWS CLI** with the developer credentials:
   ```sh
   aws configure
   # Use the Access Key ID and Secret Access Key from Terraform outputs