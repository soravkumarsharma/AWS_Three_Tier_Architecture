variable "lb_tg_name" {}
variable "lb_tg_port" {}
variable "lb_tg_protocol" {}
variable "vpc_id" {}
variable "ec2_id" {}

output "lb_tg_arn" {
  value = aws_lb_target_group.app_layer_lb_tg.arn 
}

resource "aws_lb_target_group" "app_layer_lb_tg" {
  name = var.lb_tg_name
  port = var.lb_tg_port
  protocol = var.lb_tg_protocol
  vpc_id = var.vpc_id
  health_check {
    path = "/health"
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200" 
  }
}

resource "aws_lb_target_group_attachment" "app_layer_lb_tg_attachement" {
  target_group_arn = aws_lb_target_group.app_layer_lb_tg.arn 
  target_id = var.ec2_id
  port = var.lb_tg_port
}