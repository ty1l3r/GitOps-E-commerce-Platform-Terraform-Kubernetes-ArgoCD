#-------------------------------------------------------------------------------
# CONFIGURATION DE BASE
#-------------------------------------------------------------------------------
module "commons" {
  source       = "../commons"
  project_name = var.project_name
  environment  = var.environment
}

locals {
  name = "${var.project_name}-${var.environment}"
}

#-------------------------------------------------------------------------------
# CLUSTER EKS
#-------------------------------------------------------------------------------
# Configuration des groupes de nœuds managés
data "aws_kms_key" "ebs_default" {
  key_id = "alias/aws/ebs"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Configuration de base du cluster
  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  enable_cluster_creator_admin_permissions = true

  # Configuration réseau du cluster
  vpc_id     = var.vpc_config.vpc_id
  subnet_ids = var.vpc_config.subnet_ids

  # Configuration des points d'accès du cluster
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_public_access_cidrs

  # Désactivation des fonctionnalités optionnelles
  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {} # Vide pour désactiver le chiffrement

  # Configuration des addons EKS
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Configuration des groupes de nœuds managés
  eks_managed_node_groups = {
    main = {
      name = "${var.project_name}-${var.environment}-ng"
      use_name_prefix = false
      create_iam_role = false
      iam_role_arn    = var.node_role_arn

      min_size       = var.nodes_min_size
      max_size       = var.nodes_max_size
      desired_size   = var.nodes_desired_size
      instance_types = var.instance_types
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = var.node_volume_size
            volume_type = "gp3"
            encrypted   = false
          }
        }
      }
    }
  }

  tags = merge(module.commons.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })

  enable_irsa = true # Active le support IRSA avec OIDC
}

#-------------------------------------------------------------------------------
# STORAGE CLASSES
#-------------------------------------------------------------------------------
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type      = "gp3"
    encrypted = "false"
  }
  depends_on = [module.eks]
}

# Modification de la gestion de gp2
resource "kubernetes_annotations" "remove_gp2_default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
  depends_on = [
    module.eks,
    kubernetes_storage_class.gp3
  ]
  # Ajout d'un bloc provisioner pour gérer l'erreur si gp2 n'existe pas
  provisioner "local-exec" {
    command    = "kubectl get storageclass gp2 || kubectl create storageclass gp2 --provisioner=kubernetes.io/aws-ebs"
    on_failure = continue
  }
}

locals {
  oidc_provider_arn = module.eks.oidc_provider_arn
}
