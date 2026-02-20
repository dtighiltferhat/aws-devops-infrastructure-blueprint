locals {
  common_tags = merge(
    {
      Project     = "aws-devops-infrastructure-blueprint"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

# --- ALB: Target 5xx errors ---
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name          = "${var.name}-alb-target-5xx"
  alarm_description   = "High Target 5XX responses"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions
  tags          = local.common_tags
}

# --- ALB: Target response time ---
resource "aws_cloudwatch_metric_alarm" "alb_target_latency" {
  alarm_name          = "${var.name}-alb-target-latency"
  alarm_description   = "High target response time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  period              = 60
  statistic           = "Average"
  threshold           = 1.0
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions
  tags          = local.common_tags
}

# --- ALB: Unhealthy targets ---
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.name}-alb-unhealthy-hosts"
  alarm_description   = "Unhealthy targets behind ALB"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions
  tags          = local.common_tags
}

# --- RDS: CPU ---
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.name}-rds-cpu-high"
  alarm_description   = "High RDS CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  period              = 60
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"

  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions
  tags          = local.common_tags
}

# --- RDS: Free storage ---
resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  alarm_name          = "${var.name}-rds-free-storage-low"
  alarm_description   = "Low RDS free storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_free_storage_threshold_bytes
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"

  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions
  tags          = local.common_tags
}

# Optional: a simple dashboard
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0, y = 0, width = 12, height = 6
        properties = {
          title = "ALB Target 5XX"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        x = 12, y = 0, width = 12, height = 6
        properties = {
          title = "RDS CPU"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type = "metric"
        x = 12, y = 6, width = 12, height = 6
        properties = {
          title = "RDS FreeStorageSpace"
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_identifier]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type = "metric"
        x = 0, y = 6, width = 12, height = 6
        properties = {
          title = "ALB UnHealthyHostCount"
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
          period = 60
          stat   = "Average"
        }
      }
    ]
  })
}
