locals {
  common_tags = merge(
    {
      Project     = "aws-devops-infrastructure-blueprint"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Read the DB password from SSM Parameter Store
data "aws_ssm_parameter" "db_password" {
  name            = var.password_ssm_param_name
  with_decryption = true
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags   = merge(local.common_tags, {
    Name = "${var.name}-db-subnet-group"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "DB SG: allow inbound only from app SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow DB from app/EC2 SG"
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    description = "Allow all outbound (patching/telemetry)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags   = merge(local.common_tags, {
    Name = "${var.name}-db-sg"
  })
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-rds"

  engine         = var.engine
  engine_version = var.engine_version
  port           = var.port

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.username
  password = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az            = var.multi_az
  storage_encrypted   = true

  backup_retention_period = var.backup_retention_period

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-${var.environment}-final"

  # Good defaults for dev/portfolio
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags   = merge(local.common_tags, {
    Name = "${var.name}-rds"
  })
}
