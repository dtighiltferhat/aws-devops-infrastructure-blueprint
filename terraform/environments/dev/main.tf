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
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids

  # App defaults (we'll align EC2 to these later)
  listener_port      = 80
  listener_protocol  = "HTTP"
  target_port        = 80
  target_protocol    = "HTTP"
  health_check_path  = "/"
 
  enable_https                  = true
  certificate_arn               = var.certificate_arn
  enable_http_to_https_redirect = true

  tags = var.tags
}

module "ec2" {
  source = "../../modules/ec2"

  name        = var.name
  environment = var.environment

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids

  alb_sg_id         = module.alb.alb_sg_id
  target_group_arn  = module.alb.target_group_arn

  app_port          = 80
  instance_type     = "t3.micro"

  min_size          = 1
  desired_capacity  = 2
  max_size          = 3

  enable_ssm         = true
  enable_autoscaling = true
  scale_policy       = "cpu"
  cpu_target_value   = 50

  tags       = var.tags
}

module "rds" {
  source = "../../modules/rds"

  name        = var.name
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids

  # Allow DB access ONLY from app instances
  app_sg_id = module.ec2.app_sg_id

  engine         = "postgres"
  engine_version = "16.1"
  port           = 5432

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name   = "appdb"
  username  = "appadmin"

  # Store DB password in SSM SecureString
  password_ssm_param_name = "/aws-devops-infrastructure-blueprint/dev/db_password"

  multi_az                = false
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true


  tags = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  name        = var.name
  environment = var.environment
  tags        = var.tags

  alb_arn_suffix           = module.alb.alb_arn_suffix
  target_group_arn_suffix  = module.alb.target_group_arn_suffix
  db_identifier            = module.rds.db_identifier

  # sns_topic_arn = "" # optional later
}


