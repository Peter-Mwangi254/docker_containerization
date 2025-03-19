# Terraform AWS Infrastructure with Dockerized Application

This project provisions an AWS infrastructure using Terraform and deploys a Python-based application in a Docker container on an EC2 instance. Additionally, it includes a script to store the EC2 instance's public IP address in AWS Systems Manager (SSM) Parameter Store for easy access and integration with other AWS services.

## Prerequisites
Before deploying this infrastructure, ensure you have the following:

- **Terraform installed**: Download and install Terraform from the official website.
- **AWS CLI installed and configured**: Set up the AWS CLI with valid credentials by running `aws configure`.
- **SSH key pair**: Generate an SSH key pair using the `ssh-keygen` command or use an existing key. Save the public key locally.
- **Docker installed**: To build and test the Docker image locally before deployment.
- **Variables**: Provide the required variables in a `terraform.tfvars` file or through environment variables.

## Features
This setup includes the following:

### Infrastructure Provisioned by Terraform
- **VPC**: A Virtual Private Cloud with DNS hostnames enabled.
- **Public Subnet**: A public subnet for hosting the EC2 instance.
- **Internet Gateway**: Allows internet access for the resources.
- **Route Table**: Configures routing for internet traffic.
- **Security Group**:
  - Open ports for SSH (22), HTTP (80), HTTPS (443), and the application (8080).
- **Key Pair**: An AWS key pair created using your SSH public key.
- **EC2 Instance**:
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
cd docker_containerization
```

### 2. Set Up Variables
Provide values for the required Terraform variables:

```hcl
aws_region       = "us-east-1" # Replace with your AWS region
ami_id           = "ami-0abcdef1234567890" # Replace with a valid AMI ID
instance_type    = "t2.micro" # Replace with your desired instance type
public_key_path  = "~/.ssh/id_rsa.pub" # Replace with the path to your SSH public key
```

### 3. Initialize Terraform
Navigate to the Terraform directory and initialize Terraform:

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

### 4. Store the EC2 Public IP in AWS SSM Parameter Store
Once the infrastructure is created, navigate to the `scripts` directory and run the `store_ec2_ip.sh` script to store the EC2 instance's public IP address in AWS Systems Manager (SSM) Parameter Store.

```bash
./store_ec2_ip.sh
```

### 5. Test the Docker Build and Push
Before deploying, test building and pushing the Docker image to Docker Hub.

```bash
# Build the Docker image
docker build -t $DOCKER_USERNAME/my-docker-app:latest .

# Login to Docker Hub
docker login

# Push the image
docker push $DOCKER_USERNAME/my-docker-app:latest
```

### 6. Connect to the EC2 Instance
Retrieve the public IP of the instance from AWS SSM Parameter Store and connect via SSH:

```bash
EC2_IP=$(aws ssm get-parameter --name "/docker-app/ec2-ip" --query "Parameter.Value" --output text)
ssh -i ~/.ssh/id_rsa ubuntu@$EC2_IP
```

### 7. Pull and Run the Docker Image on EC2
Once connected to the EC2 instance, pull the latest Docker image and run it:

```bash
# Login to Docker Hub
docker login

# Pull the latest image
docker pull $DOCKER_USERNAME/my-docker-app:latest

# Stop and remove any existing container
docker stop my-app-container || true
docker rm my-app-container || true

# Run the new container
docker run -d --name my-app-container -p 80:80 $DOCKER_USERNAME/my-docker-app:latest
```

### 8. Verify Deployment
Check if the container is running successfully:

```bash
docker ps
```

Access the application in your browser using the EC2 instance’s public IP:

```bash
http://$EC2_IP
```


### 10. Destroy Infrastructure (If Needed)
To remove the AWS resources created by Terraform, run:

```bash
terraform destroy -auto-approve
```

## 🎉 Congratulations! Your application is now deployed on AWS using Terraform and Docker! 🚀
