##############################
# Terraform + AWS Provider
##############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

##############################
# Security Group (allow HTTP)
##############################
resource "aws_security_group" "demo_sg" {
  name_prefix = "demo-sg-"
  description = "Allow SSH and HTTP inbound traffic"

  # SSH (required for Ansible)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # HTTP for Web Server
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "Terraform-Demo-SG"
  }
}

##############################
# EC2 Instance
##############################
resource "aws_instance" "demo_ec2" {
  ami                    = "ami-0c398cb65a93047f2" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  key_name = "terraform"

  monitoring = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Forces IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "Terraform-Demo-EC2"
  }
}
