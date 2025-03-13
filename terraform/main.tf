terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "docker_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "docker-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "docker_public_subnet" {
  vpc_id                  = aws_vpc.docker_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "docker-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "docker_igw" {
  vpc_id = aws_vpc.docker_vpc.id
  tags = {
    Name = "docker-igw"
  }
}

# Route Table
resource "aws_route_table" "docker_public_rt" {
  vpc_id = aws_vpc.docker_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker_igw.id
  }
  tags = {
    Name = "docker-public-rt"
  }
}

# Associate Route Table
resource "aws_route_table_association" "docker_rta" {
  subnet_id      = aws_subnet.docker_public_subnet.id
  route_table_id = aws_route_table.docker_public_rt.id
}

# Security Group
resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Allow SSH and custom app ports"
  vpc_id      = aws_vpc.docker_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    # Allow Django application traffic on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker-sg"
  }
}

# Key Pair
resource "aws_key_pair" "docker_key" {
  key_name   = "docker-key"
  public_key = file(var.public_key_path)
}

# EC2 Instance
resource "aws_instance" "docker_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.docker_key.key_name
  subnet_id              = aws_subnet.docker_public_subnet.id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              sudo apt-get update

              # Install Docker
              sudo apt-get install -y docker.io

              # Start Docker service
              sudo systemctl start docker
              sudo systemctl enable docker

              # Add ubuntu user to the docker group
              sudo usermod -aG docker ubuntu

              # Install git
              sudo apt-get install -y git

              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              # Install AWS CLI
              sudo apt-get install -y awscli

              # Install and configure CodeDeploy agent
              sudo apt-get install -y ruby wget
              cd /home/ubuntu
              wget https://aws-codedeploy-${var.aws_region}.s3.amazonaws.com/latest/install
              sudo chmod +x ./install
              sudo ./install auto

              # Clean up
              sudo apt-get clean
              EOF

  tags = {
    Name = "docker-ec2"
  }
}

# Output the public IP
output "ec2_public_ip" {
  value = aws_instance.docker_ec2.public_ip
}
