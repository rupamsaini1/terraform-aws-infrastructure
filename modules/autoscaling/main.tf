resource "aws_autoscaling_group" "this" {

  name = var.name

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns

  health_check_type = var.health_check_type

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  instance_refresh {
  strategy = "Rolling"

  preferences {
    min_healthy_percentage = 100
  }
  }
}