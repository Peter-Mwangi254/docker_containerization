# Terraform AWS Infrastructure with Dockerized Application

This project provisions an AWS infrastructure using Terraform and deploys a Python-based application in a Docker container on an EC2 instance. Additionally, it includes a script to store the EC2 instance's public IP address in AWS Systems Manager (SSM) Parameter Store for easy access and integration with other AWS services.

---

## Prerequisites

Before deploying this infrastructure, ensure you have the following:

1. **Terraform installed**: Download and install Terraform from the [official website](https://www.terraform.io/downloads).
2. **AWS CLI installed and configured**: Set up the AWS CLI with valid credentials by running `aws configure`.
3. **SSH key pair**: Generate an SSH key pair using the `ssh-keygen` command or use an existing key. Save the public key locally.
4. **Docker installed**: To build and test the Docker image locally before deployment.
5. **Variables**: Provide the required variables in a `terraform.tfvars` file or through environment variables.

---

## Features

This setup includes the following:

### Infrastructure Provisioned by Terraform
1. **VPC**: A Virtual Private Cloud with DNS hostnames enabled.
2. **Public Subnet**: A public subnet for hosting the EC2 instance.
3. **Internet Gateway**: Allows internet access for the resources.
4. **Route Table**: Configures routing for internet traffic.
5. **Security Group**:
   - Open ports for SSH (22), HTTP (80), HTTPS (443), and the application (8080).
6. **Key Pair**: An AWS key pair created using your SSH public key.
7. **EC2 Instance**:
   - Pre-configured with Docker, Docker Compose, AWS CLI, and CodeDeploy agent.
   - Runs the containerized Python application.

### Application Details
- The Python application is containerized using a multi-stage Docker build for efficiency and security.
- The container exposes the application on port `8080`.

### EC2 Public IP Storage
- A Bash script retrieves the EC2 instance's public IP from Terraform output and stores it in AWS Systems Manager (SSM) Parameter Store.

---

## Step-by-Step Instructions

### 1. Clone the Repository
Clone the repository containing the Terraform configuration, application code, and script.

```bash
git clone https://github.com/Peter-Mwangi254/docker_containerization.git
cd terraform
```
