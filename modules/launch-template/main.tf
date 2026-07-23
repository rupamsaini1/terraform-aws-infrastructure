resource "aws_launch_template" "this" {
  name_prefix            = "${var.name}-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  user_data              = var.user_data != null ? base64encode(var.user_data) : null

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [var.iam_instance_profile] : []

    content {
      name = iam_instance_profile.value
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  tags = var.tags

  tag_specifications {
    resource_type = "instance"

    tags = var.tags
  }

  tag_specifications {
    resource_type = "volume"

    tags = var.tags
  }

  lifecycle {

    create_before_destroy = true

  }
}