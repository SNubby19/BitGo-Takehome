resource "aws_iam_role" "ecs_node_role" {
  name = "ecs-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name = "ecs-node-profile"
  role = aws_iam_role.ecs_node_role.name
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "ecs_node" {
  name_prefix   = "ecs-node-"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = "t3.micro" # Cheap and perfect for this test

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_node.arn
  }

  vpc_security_group_ids = [aws_security_group.ecs.id] # Attach your private bouncer!

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "ecs_nodes" {
  name                = "ecs-cluster-asg"
  vpc_zone_identifier = aws_subnet.public[*].id # Spread across your public subnets
  min_size            = 2 # Always keep 2 running for High Availability
  max_size            = 4 # Cap it at 4 to control costs
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.ecs_node.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-cluster-node"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "scale-on-cpu"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ecs_nodes.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
