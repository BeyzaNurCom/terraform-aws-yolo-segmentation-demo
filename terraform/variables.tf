variable "aws_region" {
  default = "eu-central-1"
}

variable "project_name" {
  default = "yolo-segmentation-demo"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.11.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.2.0/24", "10.0.12.0/24"]
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
}

variable "instance_type" {
  default = "t3.micro"
}

variable "github_repo_url" {
  description = "Public GitHub repository URL"
  type        = string
}

variable "app_port" {
  default = 5000
}
