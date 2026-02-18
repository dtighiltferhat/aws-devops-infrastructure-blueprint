output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.vpc.nat_gateway_ids
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_sg_id" {
  value = module.alb.alb_sg_id
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "app_sg_id" {
  value = module.ec2.app_sg_id
}

output "asg_name" {
  value = module.ec2.asg_name
}
