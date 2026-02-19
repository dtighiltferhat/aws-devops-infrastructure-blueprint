variable "name"        { type = string }
variable "environment" { type = string }
variable "region"      { type = string }

variable "vpc_cidr" { type = string }

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

# ALB / ACM
variable "certificate_arn" {
  description = "ACM certificate ARN in the same region as the ALB"
  type        = string
}

# EC2 sizing for prod
variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

# RDS sizing for prod
variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

# Optional later
# variable "sns_topic_arn" {
#   type    = string
#   default = ""
# }
