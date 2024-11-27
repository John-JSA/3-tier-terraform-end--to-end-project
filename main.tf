provider "aws" {
  region = "us-east-1"

}

module "vpc" {
  source = "./vpc"
  vpc_cidr_block = var.vpc_cidr_block
  tags = local.project_tags
  public_subnet_cidr_block = var.public_subnet_cidr_block
  availability_zone = var.availability_zone
  private_subnet_cidr = var.private_subnet_cidr
} 


