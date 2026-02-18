bucket         = "aws-devops-infrastructure-blueprint-tfstate"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "aws-devops-infrastructure-blueprint-tflock"
encrypt        = true
