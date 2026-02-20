variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the ASG"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ALB security group ID (allowed inbound source)"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN to attach ASG instances"
  type        = string
}

variable "app_port" {
  description = "Application port on instances"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "ASG min size"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "ASG max size"
  type        = number
  default     = 3
}

variable "ami_id" {
  description = "Optional AMI ID override. If empty, uses latest Amazon Linux 2023 via SSM."
  type        = string
  default     = ""
}

variable "enable_ssm" {
  description = "Attach IAM role for AWS Systems Manager (recommended)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "Enable target tracking autoscaling policies"
  type        = bool
  default     = true
}

variable "scale_policy" {
  description = "Autoscaling strategy: cpu or alb_request"
  type        = string
  default     = "cpu"
  validation {
    condition     = contains(["cpu", "alb_request"], var.scale_policy)
    error_message = "scale_policy must be one of: cpu, alb_request."
  }
}

variable "cpu_target_value" {
  description = "Target average CPU utilization (%)"
  type        = number
  default     = 50
}

variable "alb_requests_per_target" {
  description = "ALB request count per target (requests/period)"
  type        = number
  default     = 100
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix (required for alb_request policy)"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix (required for alb_request policy)"
  type        = string
  default     = ""
}
