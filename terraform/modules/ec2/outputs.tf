output "app_sg_id" {
  description = "Security Group ID for app instances"
  value       = aws_security_group.app.id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.this.id
}
