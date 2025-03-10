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
# FLUENTD IRSA
#-------------------------------------------------------------------------------
resource "aws_iam_role" "fluentd" {
  name = "${local.name}-fluentd"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider}:sub" : "system:serviceaccount:logging:fluentd"
        }
      }
    }]
  })

  tags = module.commons.tags
}

resource "aws_iam_role_policy" "fluentd_s3" {
  name = "${local.name}-fluentd-s3"
  role = aws_iam_role.fluentd.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObjectTagging",
        "s3:DeleteObject"
      ]
      Resource = [
        "${var.logs_bucket_arn}/*",
        var.logs_bucket_arn
      ]
    }]
  })
}

#-------------------------------------------------------------------------------
# MONGODB BACKUP IRSA
#-------------------------------------------------------------------------------
resource "aws_iam_role" "mongodb_backup" {
  name = "${local.name}-mongodb-backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider}:sub" : "system:serviceaccount:mongodb:mongodb-backup"
        }
      }
    }]
  })

  tags = module.commons.tags
}

resource "aws_iam_role_policy" "mongodb_s3" {
  name = "${local.name}-mongodb-s3"
  role = aws_iam_role.mongodb_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "${var.backup_bucket_arn}/mongodb/*",
        var.backup_bucket_arn
      ]
    }]
  })
}

#-------------------------------------------------------------------------------
# VELERO IRSA
#-------------------------------------------------------------------------------
resource "aws_iam_role" "velero" {
  name = "${local.name}-velero"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc_provider_arn # Ceci contient déjà l'ARN complet du provider OIDC
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider}:aud" : "sts.amazonaws.com",
          "${var.eks_oidc_provider}:sub" : "system:serviceaccount:velero:velero"
        }
      }
    }]
  })

  tags = module.commons.tags
}

# Politique complète pour Velero
resource "aws_iam_role_policy" "velero_s3" {
  name = "${local.name}-velero-s3"
  role = aws_iam_role.velero.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging"
        ]
        Resource = [
          "${var.backup_bucket_arn}/*",
          var.backup_bucket_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      }
    ]
  })
}

# Ajouter le data source
data "aws_caller_identity" "current" {}



