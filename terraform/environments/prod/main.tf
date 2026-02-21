module "vpc" {
  source = "../../modules/vpc"

  name        = var.name
  environment = var.environment
  region      = var.region

  vpc_cidr             = var.vpc_cidr
  az_count             = 3
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  name        = var.name
  environment = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  listener_port     = 80
  listener_protocol = "HTTP"
  target_port       = 80
  target_protocol   = "HTTP"
  health_check_path = "/"

  enable_https                  = true
  certificate_arn               = var.certificate_arn
  enable_http_to_https_redirect = true

  tags = var.tags
}

module "ec2" {
  source = "../../modules/ec2"

  name        = var.name
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  app_port      = 80
  instance_type = var.instance_type

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  enable_ssm                = true
  enable_autoscaling        = true
  scale_policy              = "alb_request"
  alb_requests_per_target   = 100
  alb_arn_suffix            = module.alb.alb_arn_suffix
  target_group_arn_suffix   = module.alb.target_group_arn_suffix
  
  tags = var.tags
}

module "rds" {
  source = "../../modules/rds"

  name        = var.name
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  app_sg_id = module.ec2.app_sg_id

  engine         = "postgres"
  engine_version = "16.1"
  port           = 5432

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = "appdb"
  username = "appadmin"

  password_ssm_param_name = "/aws-devops-infrastructure-blueprint/prod/db_password"

  multi_az                = true
  backup_retention_period = 14
  deletion_protection     = true
  skip_final_snapshot     = false
  apply_immediately       = false

  tags = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  name        = var.name
  environment = var.environment
  tags        = var.tags

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  enable_rds_alarms       = true
  db_identifier           = module.rds.db_identifier

  # sns_topic_arn = var.sns_topic_arn
  # rds_free_storage_threshold_bytes = 2147483648 # optional override
}
