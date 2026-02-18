module "vpc" {
  source = "../../modules/vpc"

  name        = var.name
  environment = var.environment
  region      = var.region

  vpc_cidr             = var.vpc_cidr
  az_count             = 3
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  name        = var.name
  environment = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids

  # App defaults (we'll align EC2 to these later)
  listener_port      = 80
  listener_protocol  = "HTTP"
  target_port        = 80
  target_protocol    = "HTTP"
  health_check_path  = "/"

  tags = var.tags
}

module "ec2" {
  source = "../../modules/ec2"

  name        = var.name
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids

  alb_sg_id         = module.alb.alb_sg_id
  target_group_arn  = module.alb.target_group_arn

  app_port          = 80
  instance_type     = "t3.micro"

  min_size          = 1
  desired_capacity  = 2
  max_size          = 3

  enable_ssm = true
  tags       = var.tags
}

