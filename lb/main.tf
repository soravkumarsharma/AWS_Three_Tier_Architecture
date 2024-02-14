variable "lb_name" {}
variable "lb_type" {}
variable "lb_sg" {}
variable "subnets_id" {}
variable "lb_tg_arn" {}
variable "ec2_instance_id" {}
variable "lb_tg_attachement_port" {}
variable "lb_listner_port" {}
variable "lb_listner_protocol" {}
variable "lb_listner_default_action" {}
variable "tg_arn" {}
variable "is_internal_lb" {}

resource "aws_lb" "app_internal_lb" {
  name = var.lb_name
  internal = var.is_internal_lb 
  load_balancer_type = var.lb_type
  security_groups = [var.lb_sg]
  subnets = var.subnets_id
  enable_deletion_protection = false 
  tags = {
    Name = var.lb_name
  }
}

resource "aws_lb_target_group_attachment" "lb_tg_attachement" {
  target_group_arn = var.lb_tg_arn 
  target_id = var.ec2_instance_id
  port = var.lb_tg_attachement_port
}

resource "aws_lb_listener" "lb_listner" {
  load_balancer_arn = aws_lb.app_internal_lb.arn 
  port = var.lb_listner_port
  protocol = var.lb_listner_protocol
  default_action {
    type = var.lb_listner_default_action
    target_group_arn = var.tg_arn
  }
}
