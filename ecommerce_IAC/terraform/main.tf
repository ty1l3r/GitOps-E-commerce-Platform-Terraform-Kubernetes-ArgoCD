#===============================================================================
# INFRASTRUCTURE DE BASE
#===============================================================================
module "commons" {
  source       = "./modules/commons"
  project_name = var.project_name
  environment  = var.environment
}

# Ajout de la variable locale pour le nom du cluster
locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
}

# 1. VPC
module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  environment        = var.environment
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
}

# 2. Public Subnets
module "public_subnets" {
  source                = "./modules/subnets"
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  availability_zones    = var.availability_zones
  subnets_cidr          = var.public_subnets_cidr
  public_subnets_cidr   = var.public_subnets_cidr
  public_route_table_id = module.vpc.public_route_table_id
  cluster_name          = local.cluster_name
  private               = false
  depends_on            = [module.vpc]
}

# 3. NAT Gateways
module "nat" {
  source             = "./modules/nat"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  public_subnet_ids  = module.public_subnets.public_subnet_ids
  depends_on         = [module.public_subnets]
}

# 4. Private Subnets
module "private_subnets" {
  source               = "./modules/subnets"
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  subnets_cidr         = var.private_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  nat_gateway_ids      = module.nat.nat_gateway_ids
  cluster_name         = local.cluster_name
  private              = true
  depends_on           = [module.vpc, module.nat]
}

# 2. Stockage S3 (déplacé avant IAM)
module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  environment    = var.environment
  retention_days = var.retention_days
}

module "ebs" {
  source       = "./modules/ebs"
  project_name = var.project_name
  environment  = var.environment
  depends_on   = [module.vpc]
}

# 3. IAM Base (après S3)
module "iam_base" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  tfstate_bucket     = var.tf_state_bucket
  backup_bucket_name = module.s3.backup_bucket.name # Ajout de cette ligne
  depends_on         = [module.s3]
}

# 4. EKS (avec les dépendances dans le bon ordre)
module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name
  environment  = var.environment
  cluster_name = local.cluster_name
  vpc_config = {
      vpc_id     = module.vpc.vpc_id
      subnet_ids = module.private_subnets.private_subnet_ids
    }
  eks_admins_iam_role_arn = module.iam_base.eks_admin_role_arn # L'output existe maintenant
  mongodb_storage_class   = var.mongodb_storage_class
  node_role_arn           = module.iam_base.node_group_role_arn # L'output existe maintenant
  depends_on = [
    module.vpc,
    module.private_subnets,
    module.public_subnets,
    module.iam_base,
    module.s3
  ]
}

# 5. IAM IRSA (après EKS)
module "iam_irsa" {
  source                = "./modules/iam-irsa"
  project_name          = var.project_name
  environment           = var.environment
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  backup_bucket_arn     = module.s3.backup_bucket.arn
  logs_bucket_arn       = module.s3.logs_bucket.arn
  tf_state_bucket       = var.tf_state_bucket
  depends_on            = [module.eks]
}

module "argocd" {
  source = "./modules/argocd"

  # Configuration pour le repo MANIFEST
  gitlab_repo_url       = "git@gitlab.com:repo-prod-manifest.git"
  app_repository_secret = var.app_repository_secret
  domain_name           = var.domain_name
  environment           = var.environment

  helm_dependencies = [
    module.helm.nginx_ingress_hostname
  ]

  depends_on = [
    module.helm.nginx_ingress_hostname,
    module.eks
  ]
}

# 6. Helm
module "helm" {
  source = "./modules/helm"

  project_name                       = var.project_name
  environment                        = var.environment
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_oidc_issuer_url            = module.eks.cluster_oidc_issuer_url
  domain_name                        = var.domain_name
  grafana_password                   = var.grafana_password
  cert_manager_email                 = var.cert_manager_email
  aws_region                         = var.aws_region
  velero_bucket_name                 = module.s3.backup_bucket.name
  logs_bucket_name                   = module.s3.logs_bucket.name
  velero_role_arn                    = module.iam_irsa.velero_role_arn
  fluentd_role_arn                   = module.iam_irsa.fluentd_role_arn

  depends_on = [
    module.eks,
    module.iam_irsa,
    module.s3
  ]
}


