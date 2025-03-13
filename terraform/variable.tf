variable "aws_region" {
  description = "AWS region to launch resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu"
  default     = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04 LTS in us-east-1, update for your region
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to public key for SSH access"
  default     = "~/.ssh/id_rsa.pub"
}
