#===============================================================================
# OUTPUTS MODULE EBS
#===============================================================================

# Configuration des volumes EBS pour tous les services
# Structure:
#   service_name:
#     primary:
#       id: ID du volume EBS
#       name: Nom du volume (depuis les tags)
#       az: Zone de disponibilité
#     replica: (pour utilisation future en HA)
output "volumes" {
  description = "Configuration des volumes EBS"
  value = {
    # MongoDB Customers - Service de gestion des clients
    mongodb_customers = {
      primary = {
        id   = aws_ebs_volume.mongodb_customers_primary.id
        name = aws_ebs_volume.mongodb_customers_primary.tags["Name"]
        az   = aws_ebs_volume.mongodb_customers_primary.availability_zone
      }
      # Pour future HA - Décommenter et configurer le replica
      # replica = {
      #   id   = aws_ebs_volume.mongodb_customers_replica.id
      #   name = aws_ebs_volume.mongodb_customers_replica.tags["Name"]
      #   az   = aws_ebs_volume.mongodb_customers_replica.availability_zone
      # }
    }

    # MongoDB Products - Service de gestion des produits
    mongodb_products = {
      primary = {
        id   = aws_ebs_volume.mongodb_products_primary.id
        name = aws_ebs_volume.mongodb_products_primary.tags["Name"]
        az   = aws_ebs_volume.mongodb_products_primary.availability_zone
      }
      # Pour future HA - Décommenter et configurer le replica
      # replica = {
      #   id   = aws_ebs_volume.mongodb_products_replica.id
      #   name = aws_ebs_volume.mongodb_products_replica.tags["Name"]
      #   az   = aws_ebs_volume.mongodb_products_replica.availability_zone
      # }
    }

    # MongoDB Shopping - Service de gestion des paniers
    mongodb_shopping = {
      primary = {
        id   = aws_ebs_volume.mongodb_shopping_primary.id
        name = aws_ebs_volume.mongodb_shopping_primary.tags["Name"]
        az   = aws_ebs_volume.mongodb_shopping_primary.availability_zone
      }
      # Pour future HA - Décommenter et configurer le replica
      # replica = {
      #   id   = aws_ebs_volume.mongodb_shopping_replica.id
      #   name = aws_ebs_volume.mongodb_shopping_replica.tags["Name"]
      #   az   = aws_ebs_volume.mongodb_shopping_replica.availability_zone
      # }
    }

    # RabbitMQ - Service de messagerie
    rabbitmq = {
      primary = {
        id   = aws_ebs_volume.rabbitmq_primary.id
        name = aws_ebs_volume.rabbitmq_primary.tags["Name"]
        az   = aws_ebs_volume.rabbitmq_primary.availability_zone
      }
      # Pour future HA - Décommenter et configurer le replica
      # replica = {
      #   id   = aws_ebs_volume.rabbitmq_replica.id
      #   name = aws_ebs_volume.rabbitmq_replica.tags["Name"]
      #   az   = aws_ebs_volume.rabbitmq_replica.availability_zone
      # }
    }
  }
}