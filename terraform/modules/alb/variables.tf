variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will live"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB (usually across multiple AZs)"
  type        = list(string)
}

variable "listener_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "ALB listener protocol"
  type        = string
  default     = "HTTP"
}

variable "target_port" {
  description = "Target group port (your app port on EC2)"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Target group protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "enable_https" {
  description = "Enable HTTPS listener on 443"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN (must be in same region as ALB)"
  type        = string
  default     = ""
}

variable "enable_http_to_https_redirect" {
  description = "Redirect HTTP 80 to HTTPS 443 when HTTPS is enabled"
  type        = bool
  default     = true
}

