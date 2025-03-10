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
# NAT GATEWAY & EIP
#===============================================================================
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = merge(module.commons.tags, {
    Name = "${local.name}-eip-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  })
}

resource "aws_nat_gateway" "main" {
  count             = length(var.availability_zones)
  allocation_id     = aws_eip.nat[count.index].id
  subnet_id         = var.public_subnet_ids[count.index]
  connectivity_type = "public"

  tags = merge(module.commons.tags, {
    Name = "${local.name}-nat-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  })

  depends_on = [aws_eip.nat]
}