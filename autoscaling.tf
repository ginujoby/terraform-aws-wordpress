# Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "wordpress-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.wordpress.id]
  key_name               = aws_key_pair.bastion.key_name

  user_data = base64encode(templatefile("script/userdata.sh", {
    db_endpoint = replace(aws_db_instance.wordpress.endpoint, ":3306", ""),
    db_username = var.db_username,
    db_password = var.db_password,
    db_name     = var.db_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "wordpress" {
  default_cooldown    = 30
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.wordpress.arn]
  vpc_zone_identifier = aws_subnet.private_app[*].id

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                      = "wordpress-scale-up"
  autoscaling_group_name    = aws_autoscaling_group.wordpress.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 30

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
