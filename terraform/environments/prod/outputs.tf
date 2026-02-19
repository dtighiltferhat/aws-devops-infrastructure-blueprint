output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "asg_name" {
  value = module.ec2.asg_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_identifier" {
  value = module.rds.db_identifier
}
