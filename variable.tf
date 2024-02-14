variable "aws_region" { type = string }

variable "bucket_name" { type = string }

variable "iam_role_name" { type = string }

variable "vpc_name" { type = string }

variable "vpc_cidr" { type = string }

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet_availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}