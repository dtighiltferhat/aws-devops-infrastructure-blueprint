variable "region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for backend resources"
  type        = string
  default     = "aws-devops-infrastructure-blueprint"
}

variable "tags" {
  description = "Tags to apply to backend resources"
  type        = map(string)
  default     = {
    Project   = "aws-devops-infrastructure-blueprint"
    ManagedBy = "terraform"
  }
}
