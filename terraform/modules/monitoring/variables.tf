variable "name"        { 
  type = string 
}
variable "environment" {
  type = string 
}
variable "tags"        { 
  type = map(string) 
  default = {} 
}

# ALB / Target Group
variable "alb_arn_suffix"         {
  type = string 
}

variable "target_group_arn_suffix" {
  type = string 
}

# ASG
variable "asg_name" { 
  type = string 
}

# RDS
variable "db_identifier" {
  type = string 
}

# Optional notifications
variable "sns_topic_arn" {
  description = "Optional SNS topic ARN for alarm notifications"
  type        = string
  default     = ""
}

variable "rds_free_storage_threshold_bytes" {
  description = "Alarm threshold for RDS FreeStorageSpace in bytes"
  type        = number
  default     = 2147483648
}
