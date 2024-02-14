variable "vpc_id" {}
variable "internet_facing_lb_sg" {}
variable "web_tier_sg" {}
variable "internal_lb_sg" {}
variable "private_instance_sg" {}
variable "db_sg" {}

output "rds_sg_id" {
  value = aws_security_group.db_sg.id
}

output "private_instance_sg" {
  value = aws_security_group.private_instance_sg.id 
}

output "internal_lb_sg_id" {
  value = aws_security_group.internal_lb_sg.id 
}

output "external_lb_sg_id" {
  value = aws_security_group.internet_facing_lb_sg.id 
}

output "web_tier_sg_id" {
  value = aws_security_group.web_tier_sg.id 
}

resource "aws_security_group" "internet_facing_lb_sg" {
  name        = var.internet_facing_lb_sg
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  var.internet_facing_lb_sg
  }
}

resource "aws_security_group" "web_tier_sg" {
  name = var.web_tier_sg
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP request from anywhere"
    security_groups = [ aws_security_group.internet_facing_lb_sg.id ]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.web_tier_sg
  }
}

resource "aws_security_group" "internal_lb_sg" {
  name = var.internal_lb_sg
  vpc_id = var.vpc_id
  ingress {
    description = "Allow HTTP request from anywhere"
    security_groups = [ aws_security_group.web_tier_sg.id ]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.internal_lb_sg
  }
}

resource "aws_security_group" "private_instance_sg" {
  name = var.private_instance_sg
  vpc_id = var.vpc_id
  ingress {
    description = "Allow HTTP request from anywhere"
    security_groups = [ aws_security_group.internal_lb_sg.id ]
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
  }
  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }


  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.private_instance_sg
  }
}

resource "aws_security_group" "db_sg" {
  name = var.db_sg
  vpc_id = var.vpc_id
  ingress {
    description = "Allow HTTP request from anywhere"
    security_groups = [ aws_security_group.private_instance_sg.id ]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }

  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.db_sg
  }
}