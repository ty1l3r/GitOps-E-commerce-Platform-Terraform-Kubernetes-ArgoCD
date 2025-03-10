#===============================================================================
# LOCALS
#===============================================================================
module "commons" {
  source       = "../commons"
  project_name = var.project_name
  environment  = var.environment
}

locals {
  name = "${var.project_name}-${var.environment}"
}

#===============================================================================
# EBS VOLUMES - VERSION SIMPLE (MONO-AZ)
#===============================================================================

# MongoDB Customers
resource "aws_ebs_volume" "mongodb_customers_primary" {
  availability_zone = "eu-west-3a"
  size             = 3
  type             = "gp3"
  encrypted        = false

  tags = merge(module.commons.tags, {
    Name    = "${local.name}-mongodb-customers"
    Service = "mongodb-customers"
  })
}

# MongoDB Products
resource "aws_ebs_volume" "mongodb_products_primary" {
  availability_zone = "eu-west-3a"
  size             = 3
  type             = "gp3"
  encrypted        = false

  tags = merge(module.commons.tags, {
    Name    = "${local.name}-mongodb-products"
    Service = "mongodb-products"
  })
}

# MongoDB Shopping
resource "aws_ebs_volume" "mongodb_shopping_primary" {
  availability_zone = "eu-west-3a"
  size             = 3
  type             = "gp3"
  encrypted        = false

  tags = merge(module.commons.tags, {
    Name    = "${local.name}-mongodb-shopping"
    Service = "mongodb-shopping"
  })
}

# RabbitMQ
resource "aws_ebs_volume" "rabbitmq_primary" {
  availability_zone = "eu-west-3a"
  size             = 3
  type             = "gp3"
  encrypted        = false

  tags = merge(module.commons.tags, {
    Name    = "${local.name}-rabbitmq"
    Service = "rabbitmq"
  })
}

#===============================================================================
# POUR FUTURE IMPLEMENTATION HA (MULTI-AZ)
#===============================================================================
# Pour ajouter la HA plus tard, décommenter et adapter ces blocs :

# MongoDB Customers HA
# resource "aws_ebs_volume" "mongodb_customers_replica" {
#   availability_zone = "eu-west-3b"
#   size             = 2
#   type             = "gp3"
#   encrypted        = true
#   tags = merge(module.commons.tags, {
#     Name    = "${local.name}-mongodb-customers-replica"
#     Service = "mongodb-customers"
#   })
# }

# MongoDB Products HA
# resource "aws_ebs_volume" "mongodb_products_replica" {...}

# MongoDB Shopping HA
# resource "aws_ebs_volume" "mongodb_shopping_replica" {...}

# RabbitMQ HA
# resource "aws_ebs_volume" "rabbitmq_replica" {...}