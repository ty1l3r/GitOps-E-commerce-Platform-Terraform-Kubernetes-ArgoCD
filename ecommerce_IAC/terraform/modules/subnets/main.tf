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
# SUBNETS
#===============================================================================

# Subnets publics
resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(module.commons.tags, {
    Name                                        = "${local.name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  # ✅ Utilisation de var.cluster_name
    Type                                        = "Public"
    AZ                                          = var.availability_zones[count.index]
  })
}

# Subnets privés
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(module.commons.tags, {
    Name                                          = "${local.name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"             = "1"  # Different du public (elb)
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
    Type                                          = "Private"
  })
}

# Route Tables privées
resource "aws_route_table" "private" {
  count  = length(var.private_subnets_cidr)
  vpc_id = var.vpc_id

  tags = merge(module.commons.tags, {
    Name = "${local.name}-rt-private-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  })
}

# Routes NAT Gateway
resource "aws_route" "private_nat" {
  count                  = length(var.private_subnets_cidr)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_ids[count.index]
}

# Associations
resource "aws_route_table_association" "public" {
  count          = var.private ? 0 : length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = var.public_route_table_id
}

resource "aws_route_table_association" "private" {
  count          = var.private ? length(var.private_subnets_cidr) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}