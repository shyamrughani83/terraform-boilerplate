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