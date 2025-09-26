# EKS Architecture Overview & Access Guide

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Accessing the Running Application](#accessing-the-running-application)
- [Developer IAM User Credentials & Kubeconfig Instructions](#developer-iam-user-credentials--kubeconfig-instructions)



---

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

---


## Deployment Steps

1. **Cloned the Repository**
   ```sh
   git clone <repository-url>
   cd final-setup
   ```

2. **Initialize Terraform**
I initialize terraform after wring my terraform file for  my backend, vpc, eks and IAM modules.
   ```sh
   terraform init
   ```

3. **Review and Apply the Terraform Plan**
   ```sh
   terraform plan
   terraform apply
   ```
   > **Note:** You will be prompted to confirm the apply step.

4. **Retrieve Outputs**
   After a successful apply, Terraform will output important information such as the EKS cluster endpoint.

---

## Accessing the Running Application

1. **Obtain the EKS Cluster Endpoint**
   - The EKS cluster endpoint is output as `cluster_endpoint` in Terraform.
   - You can view it by running:
     ```sh
     terraform output cluster_endpoint
     ```

2. **Configure `kubectl`**
   - Install [kubectl](https://kubernetes.io/docs/tasks/tools/) and [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) if you haven't already.
   - Use the IAM credentials (see below) to configure AWS CLI:
     ```sh
     aws configure
     # Enter Access Key ID, Secret Access Key, region (e.g., us-east-1), and output format (e.g., json)
     ```
   - Generate kubeconfig for the cluster:
     ```sh
     aws eks update-kubeconfig --region <region> --name <eks_cluster_name>
     ```
     Replace `<region>` and `<eks_cluster_name>` with your actual values from the Terraform outputs.

3. **Access the Application**
   - Use `kubectl` to interact with the cluster:
     ```sh
     kubectl get pods --all-namespaces
     ```
   - You should see a list of running pods if the access is configured correctly.
   - To access the app the [url](http://a3f3f811547184326bcbe7748f55ad81-1011189989.us-east-1.elb.amazonaws.com/) given after running 
    ```sh
     kubectl get svc ui
     ```
    

---

## Developer IAM User Credentials & Kubeconfig Instructions

### Credentials

After running `terraform apply`, the following outputs are available:

- **Access Key ID**: `developer_access_key_id`
- **Secret Access Key**: `developer_secret_access_key`
- **Console Username**: `developer_console_username`
- **Console Temporary Password**: `developer_console_temp_password`

> **Note:** These outputs are marked as sensitive so I removed the output in my main directory to prevent anyone that isn't the developer from accessing it. Retrieve them using:
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

Follow these steps to set up your Kubernetes CLI (`kubectl`) as the read-only developer:

1. **Configure AWS CLI** with the developer credentials:
   ```sh
   aws configure
   # Enter the Access Key ID and Secret Access Key from the Terraform outputs
   # Enter the AWS region (e.g., us-east-1)
   # Enter your preferred output format (e.g., json)
   ```

2. **Update kubeconfig for EKS**
   - Use the following command to update your kubeconfig file with the EKS cluster details:
     ```sh
     aws eks update-kubeconfig --region <region> --name <eks_cluster_name>
     ```
     Replace `<region>` and `<eks_cluster_name>` with the values from your Terraform outputs.

   - This command will automatically add the EKS cluster context to your kubeconfig file, allowing `kubectl` to communicate with your cluster.

3. **Test Your Access**
   - Run:
     ```sh
     kubectl get pods --all-namespaces
     ```
   - As a read-only developer, you should be able to list resources but not modify them.
