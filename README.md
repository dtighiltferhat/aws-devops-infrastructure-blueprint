# AWS DevOps Infrastructure Blueprint

Enterprise-grade AWS infrastructure blueprint demonstrating Infrastructure as Code, CI/CD automation, containerization, and cloud-native deployment patterns.

[![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)]()
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)]()
[![CI/CD](https://img.shields.io/badge/CI/CD-Jenkins-red)]()

---

## 📌 Project Overview

This repository showcases how to design and automate AWS infrastructure using production-ready DevOps practices.

It includes:

- Infrastructure as Code (Terraform)
- Modular cloud architecture
- Environment separation (DEV / PROD)
- CI/CD pipeline (Jenkins)
- Containerization (Docker)
- Kubernetes deployment manifests
- Configuration management (Ansible)

---

## 🏗 Target Architecture

This infrastructure blueprint is designed to reflect a real-world cloud architecture:

- Multi-AZ VPC design
- Public subnets for load balancers
- Private subnets for compute and databases
- Remote Terraform backend (S3 + DynamoDB)
- Infrastructure modularization for reusability
- CI/CD-driven infrastructure deployment
- Containerized workloads
- Kubernetes-based service orchestration

## 🧠 Architectural Decisions

- Infrastructure split into reusable modules for scalability and maintainability
- Remote state isolated per environment to prevent cross-environment impact
- Private compute model to reduce attack surface
- Secrets managed via AWS SSM Parameter Store
- CI/CD separates validation from apply for safer production workflows

Designed to support secure, production-scale workloads with repeatable and auditable infrastructure deployments.

This project models enterprise DevOps patterns commonly used in production AWS environments.

## 💸 Cost-Safe Defaults (Portfolio Mode)

The DEV environment runs in “portfolio mode” by default to minimize AWS cost while preserving production-ready architecture patterns.

**DEV defaults:**
- `enable_nat_gateway = false` (NAT disabled)
- `enable_rds = false` (RDS disabled)
- `enable_https = false` (HTTPS disabled)
- `asg_desired_capacity = 1`
- `asg_max_size = 1`

> Note: When NAT is disabled, private instances do not have outbound internet access, so OS package installs (e.g., `dnf install`) may fail unless you enable NAT or use VPC endpoints / a pre-baked AMI.

The PROD environment can be configured to enable NAT, HTTPS, RDS, and higher scaling limits to reflect a more realistic production profile.

### Enable Production Features

You can switch from “portfolio mode” to more production-like behavior by enabling features via `terraform.tfvars` in the environment folder (e.g., `terraform/environments/dev/terraform.tfvars`).

Example:

```
# Networking
enable_nat_gateway = true
single_nat_gateway = true   # cheaper than NAT per AZ

# App entry
enable_https    = true
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxx-xxxx"

# Data layer
enable_rds = true

# Scaling (still controlled)
asg_desired_capacity = 2
asg_max_size         = 4
```

### ✅ Core (Production-Grade) Features

- Remote Terraform state stored in S3
- State locking using DynamoDB
- Separate DEV and PROD environments
- Modular infrastructure:
  - VPC
  - Public & private subnets
  - NAT Gateway (enabled in PROD; optional/disabled by default in DEV for cost control)
  - Route tables
  - Security groups
- Application Load Balancer in public subnets
- EC2 instances in private subnets
- RDS database deployed in private subnets with dedicated DB subnet group and security group isolation
- Standardized tagging strategy
- Structured outputs and documentation
- HTTPS listener with ACM certificate on ALB
- CloudWatch alarms for ALB, ASG, and RDS
- Operational dashboard for infrastructure health

---

## 🚀 CI/CD Pipeline

Jenkins pipeline stages:

1. Terraform Validate
2. Terraform Plan
3. Manual approval (for PROD)
4. Terraform Apply
5. Docker build
6. Kubernetes deployment

---

## 📂 Repository Structure

```
terraform/
  environments/
    dev/
    prod/
  modules/
    vpc/
    alb/
    ec2/
    rds/
    monitoring/

cicd/
  Jenkinsfile

docker/
  Dockerfile

kubernetes/
  deployment.yaml
  service.yaml

ansible/
  install-nginx.yml
```

Each module is independently reusable and designed to support environment-based configuration through variables.

---

## ▶️ How to Run (High Level)

> Prerequisites: AWS CLI configured with appropriate credentials and Terraform >= 1.5 (tested with 1.6).

### 1) Bootstrap remote backend (run once)

```bash
cd terraform/backend
terraform init
terraform apply
```

### 2) Set up required secrets (see RDS section below)

### 3) Initialize DEV with remote state

```bash
cd ../environments/dev
terraform init -backend-config=../../backend-config/dev.hcl
terraform plan
terraform apply
```

### 4) Tear down resources when finished

```bash
terraform destroy
```

> Note: NAT Gateways and RDS instances incur AWS charges. Destroy resources after testing to avoid unnecessary costs.

---

## 🗄️ RDS Setup (Optional – Requires enable_rds = true)

This section applies when your environment provisions RDS (DEV uses `enable_rds = true`; PROD provisions RDS by default).

### 1) Create the DB password in SSM (required)

#### 1) In Dev
```bash
aws ssm put-parameter \
  --name "/aws-devops-infrastructure-blueprint/dev/db_password" \
  --type "SecureString" \
  --value "REPLACE_WITH_STRONG_PASSWORD" \
  --overwrite
```

#### 2) In Prod
```bash
aws ssm put-parameter \
  --name "/aws-devops-infrastructure-blueprint/prod/db_password" \
  --type "SecureString" \
  --value "REPLACE_WITH_STRONG_PASSWORD" \
  --overwrite
```

### 2) Verify the parameter exists (optional)

#### 1) In Dev
```bash
aws ssm get-parameter \
  --name "/aws-devops-infrastructure-blueprint/dev/db_password" \
  --with-decryption
```

#### 2) In Prod
```bash
aws ssm get-parameter \
  --name "/aws-devops-infrastructure-blueprint/prod/db_password" \
  --with-decryption
```

### 3) After terraform apply, retrieve the RDS endpoint

```bash
terraform output db_endpoint
```

## 🔐 Security & Best Practices

- Remote backend configuration
- State locking with DynamoDB
- Environment isolation
- Modular reusable Terraform code
- Least privilege IAM (planned)
- Infrastructure validation tools (next iteration)

---

## 🔭 Next Iteration Enhancements

- Multi-account architecture
- OIDC authentication for CI/CD (no long-lived keys)
- tfsec / checkov integration
- Infracost cost visibility
- GitHub Actions pipeline alternative

---

## 📎 DevOps Case Study

This project demonstrates how cloud infrastructure, automation, and CI/CD pipelines integrate to deliver secure, reproducible, and scalable AWS environments.

Designed to reflect real-world enterprise DevOps practices.

