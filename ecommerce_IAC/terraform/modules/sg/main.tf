#===============================================================================
# COMMONS
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
# MONGODB SECURITY GROUP
#===============================================================================
resource "aws_security_group" "mongodb" {
  name        = "${local.name}-mongodb"
  description = "Security group for MongoDB"
  vpc_id      = var.vpc_id

  tags = module.commons.tags
}

resource "aws_security_group_rule" "mongodb_from_nodes" {
  security_group_id        = aws_security_group.mongodb.id
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = var.eks_nodes_security_group_id
  description              = "Allow MongoDB access from EKS nodes"
}

resource "aws_security_group_rule" "mongodb_egress" {
  security_group_id = aws_security_group.mongodb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow MongoDB outbound access"
}

#===============================================================================
# SERVICES SECURITY GROUP
#===============================================================================
resource "aws_security_group" "services" {
  name        = "${local.name}-services"
  description = "Security group for services"
  vpc_id      = var.vpc_id

  tags = module.commons.tags
}

resource "aws_security_group_rule" "services_from_nodes" {
  security_group_id        = aws_security_group.services.id
  type                     = "ingress"
  from_port                = 8001
  to_port                  = 8003
  protocol                 = "tcp"
  source_security_group_id = var.eks_nodes_security_group_id
  description              = "Allow services access from EKS nodes"
}

resource "aws_security_group_rule" "services_egress" {
  security_group_id = aws_security_group.services.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow services outbound access"
}