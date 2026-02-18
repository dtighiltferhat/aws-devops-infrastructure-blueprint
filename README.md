# AWS DevOps Infrastructure Blueprint

Enterprise-style DevOps infrastructure blueprint demonstrating Infrastructure as Code, CI/CD automation, containerization, and cloud-native deployment patterns.

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

Designed to support production-scale workloads with repeatable, auditable infrastructure deployments.

This project simulates enterprise DevOps patterns used in real production cloud environments.

### ✅ Core (Production-Grade) Features

- Remote Terraform state stored in S3
- State locking using DynamoDB
- Separate DEV and PROD environments
- Modular infrastructure:
  - VPC
  - Public & private subnets
  - NAT Gateway
  - Route tables
  - Security groups
- Application Load Balancer in public subnets
- EC2 instances in private subnets
- RDS database in private subnets with DB subnet group
- Standardized tagging strategy
- Structured outputs and documentation

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

---

## ▶️ How to Run (High Level)

### 1) Bootstrap remote backend (run once)

```bash
cd terraform/backend
terraform init
terraform apply
```

### 2) Initialize DEV with remote state

```bash
cd ../environments/dev
terraform init -backend-config=../../backend-config/dev.hcl
terraform plan
terraform apply
```

---

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

This project demonstrates how cloud infrastructure, automation, and CI/CD pipelines integrate to deliver reproducible, scalable AWS environments.

Designed to reflect real-world enterprise DevOps practices.

