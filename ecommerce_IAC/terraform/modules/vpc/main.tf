#===============================================================================
# COMMONS
#===============================================================================
module "commons" {
  source       = "../commons"
  project_name = var.project_name
  environment  = var.environment
}

#===============================================================================
# LOCALS
#===============================================================================
locals {
  name = "${var.project_name}-${var.environment}"
}

#===============================================================================
# VPC
#===============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(module.commons.tags, {
    Name                                        = "${local.name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  # ✅ Utilisation de var.cluster_name
  })
}

#===============================================================================
# INTERNET GATEWAY
#===============================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(module.commons.tags, {
    Name = "${local.name}-igw"
  })
}

#===============================================================================
# ROUTE TABLES
#===============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(module.commons.tags, {
    Name = "${local.name}-rt-public"
    Tier = "public"
  })
}