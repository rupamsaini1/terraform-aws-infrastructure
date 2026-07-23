resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"

  security_groups = var.security_group_ids
  subnets         = var.subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled = true
    path    = var.health_check_path
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port = "80"
    protocol = "HTTP"

    default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.this.arn
    }
  
}