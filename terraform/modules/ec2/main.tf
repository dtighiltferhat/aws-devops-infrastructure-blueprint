locals {
  common_tags = merge(
    {
      Project     = "aws-devops-infrastructure-blueprint"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Latest Amazon Linux 2023 AMI via SSM Parameter (x86_64)
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

locals {
  resolved_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023_ami.value
}

# Security Group: inbound ONLY from ALB SG on app_port
resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "App instances SG: allow inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow app traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-app-sg"
  })
}

# Optional SSM Role (recommended)
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ssm" {
  count              = var.enable_ssm ? 1 : 0
  name               = "${var.name}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-ec2-instance-profile"
  role  = aws_iam_role.ssm[0].name
  tags  = local.common_tags
}

# User data: install nginx + simple health page
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    dnf update -y
    dnf install -y nginx

    cat > /usr/share/nginx/html/index.html <<HTML
    <html>
      <head><title>${var.name} (${var.environment})</title></head>
      <body>
        <h1>OK - ${var.name} (${var.environment})</h1>
        <p>Served from private subnet behind ALB</p>
      </body>
    </html>
    HTML

    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = local.resolved_ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    name = var.enable_ssm ? aws_iam_instance_profile.ssm[0].name : null
  }

    metadata_options {
    http_tokens = "required"
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${var.name}-app"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.common_tags
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-launch-template"
  })
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-asg"
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []
    content {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = var.instance_refresh_min_healthy_percentage
        instance_warmup        = var.instance_refresh_warmup
      }
      triggers = ["launch_template"]
    }
  }

  # Tags propagated to instances
  tag {
    key                 = "Name"
    value               = "${var.name}-app"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Attach ASG to ALB Target Group
resource "aws_autoscaling_attachment" "tg" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  lb_target_group_arn    = var.target_group_arn
}

resource "aws_autoscaling_policy" "cpu_target" {
  count                  = (var.enable_autoscaling && var.scale_policy == "cpu") ? 1 : 0
  name                   = "${var.name}-cpu-tt"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.cpu_target_value
  }
}

resource "aws_autoscaling_policy" "alb_req_target" {
  count                  = (var.enable_autoscaling && var.scale_policy == "alb_request") ? 1 : 0
  name                   = "${var.name}-alb-req-tt"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
    }

    target_value = var.alb_requests_per_target
  }
}
