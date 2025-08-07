# Main Terraform configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.common_tags
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  common_tags        = var.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  common_tags  = var.common_tags
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  project_name           = var.project_name
  environment           = var.environment
  instance_type         = var.instance_type
  key_name              = var.key_name
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  web_security_group_id = module.security_groups.web_security_group_id
  app_security_group_id = module.security_groups.app_security_group_id
  common_tags           = var.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project_name            = var.project_name
  environment            = var.environment
  db_instance_class      = var.db_instance_class
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  private_subnet_ids     = module.vpc.private_subnet_ids
  db_security_group_id   = module.security_groups.db_security_group_id
  common_tags            = var.common_tags
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}

# ECS Module (optional - comment out if using EKS)
module "ecs" {
  source = "./modules/ecs"
  
  project_name           = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_security_group_id
  alb_security_group_id = module.security_groups.alb_security_group_id
  ecr_repository_url    = module.ecr.repository_url
  task_cpu              = var.ecs_task_cpu
  task_memory           = var.ecs_task_memory
  container_port        = var.ecs_container_port
  desired_count         = var.ecs_desired_count
  common_tags           = var.common_tags
}

# EKS Module (optional - comment out if using ECS)
module "eks" {
  source = "./modules/eks"
  
  project_name       = var.project_name
  environment        = var.environment
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  kubernetes_version = var.kubernetes_version
  node_instance_type = var.eks_node_instance_type
  desired_nodes      = var.eks_desired_nodes
  min_nodes          = var.eks_min_nodes
  max_nodes          = var.eks_max_nodes
  common_tags        = var.common_tags
}