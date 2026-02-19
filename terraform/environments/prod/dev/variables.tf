variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "name" {
  type        = string
  description = "Name prefix for resources"
  default     = "dev-blueprint"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  # 3 AZs
  default     = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
  # 3 AZs
  default     = ["10.10.128.0/20", "10.10.144.0/20", "10.10.160.0/20"]
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {
    Owner = "dtighiltferhat"
  }
}
