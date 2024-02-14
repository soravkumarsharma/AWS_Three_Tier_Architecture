variable "public_key_path" {}
variable "ami_id" {}
variable "instance_name" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "sg_for_app" {}
variable "role_arn" {}
variable "key_pair_name" {}


output "ec2_id" {
  value = aws_instance.AppLayer_instance.id 
}

resource "aws_instance" "AppLayer_instance" {
  ami = var.ami_id
  key_name = aws_key_pair.app_key_name.key_name
  instance_type = var.instance_type 
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.sg_for_app
  tags = {
    Name = var.instance_name
  }
  iam_instance_profile = var.role_arn
  metadata_options {
    http_endpoint = "enabled"  
    http_tokens   = "required" 
  }
}

resource "aws_key_pair" "app_key_name" {
  key_name   = var.key_pair_name
  public_key = file("${var.public_key_path}")
}