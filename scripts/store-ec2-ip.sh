#!/bin/bash

# Navigate to the Terraform directory
cd /workspaces/Docker/terraform || exit

# Get the EC2 public IP from Terraform output
EC2_IP=$(terraform output -raw ec2_public_ip)

# Check if EC2_IP is empty
if [[ -z "$EC2_IP" ]]; then
  echo "Error: EC2 public IP not found in Terraform state."
  exit 1
fi

# Store the IP address in AWS SSM Parameter Store
aws ssm put-parameter \
  --name "/docker-app/ec2-ip" \
  --type "String" \
  --value "$EC2_IP" \
  --overwrite

echo "EC2 IP address ($EC2_IP) stored in SSM Parameter Store"
