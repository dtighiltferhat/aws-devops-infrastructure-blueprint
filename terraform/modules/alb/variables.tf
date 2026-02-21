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
  validation {
    condition     = contains(["HTTP"], upper(var.listener_protocol))
    error_message = "listener_protocol must be HTTP. HTTPS is configured separately via enable_https."
  }
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
  description     = "ACM certificate ARN (must be in same region as ALB)"
  type            = string
  default         = null
  validation {
    condition     = (var.enable_https == false) || (length(var.certificate_arn) > 0)
    error_message = "certificate_arn must be set when enable_https=true."
  }
}

variable "enable_http_to_https_redirect" {
  description = "Redirect HTTP 80 to HTTPS 443 when HTTPS is enabled"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  type        = bool
  default     = false
}

variable "enable_access_logs" { 
  type        = bool 
  default     = false 
}

variable "access_logs_bucket" {
  type        = string 
  default     = "" 
  validation {
    condition     = (var.enable_access_logs == false) || (length(var.access_logs_bucket) > 0)
    error_message = "access_logs_bucket must be set when enable_access_logs=true."
  }
}

variable "access_logs_prefix" {
  type        = string 
  default     = "" 
}
