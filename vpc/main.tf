locals {
  public_subnets = {
    for index, cidr in var.public_subnet_cidrs :
    index => {
      cidr_block        = cidr
      availability_zone = var.availability_zones[index]
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs :
    index => {
      cidr_block        = cidr
      availability_zone = var.availability_zones[index]
    }
  }

  database_subnets = {
    for index, cidr in var.database_subnet_cidrs :
    index => {
      cidr_block        = cidr
      availability_zone = var.availability_zones[index]
    }
  }

  nat_gateway_indexes = var.nat_gateway_strategy == "single" ? toset(["0"]) : toset([
    for index in range(length(var.availability_zones)) : tostring(index)
  ])
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = var.name
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-public-${each.value.availability_zone}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-private-${each.value.availability_zone}"
      Tier = "private"
    }
  )
}

resource "aws_subnet" "database" {
  for_each = local.database_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-database-${each.value.availability_zone}"
      Tier = "database"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_db_subnet_group" "this" {
  name = "${var.name}-database-subnet-group"

  subnet_ids = values(aws_subnet.database)[*].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-database-subnet-group"
    }
  )
}

# -----------------------------------------------------------------------------
# NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_eip" "nat" {
  for_each = local.nat_gateway_indexes

  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-nat-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateway_indexes

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-nat-${each.key}"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]
}

# -----------------------------------------------------------------------------
# Private Route Tables
# -----------------------------------------------------------------------------

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-private-rt-${each.key}"
      Tier = "private"
    }
  )
}

resource "aws_route" "private_nat" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.nat_gateway_strategy == "single" ? (
    aws_nat_gateway.this["0"].id
    ) : (
    aws_nat_gateway.this[each.key].id
  )
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# -----------------------------------------------------------------------------
# Database Route Tables
# -----------------------------------------------------------------------------

resource "aws_route_table" "database" {
  for_each = aws_subnet.database

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-database-rt-${each.key}"
      Tier = "database"
    }
  )
}

resource "aws_route_table_association" "database" {
  for_each = aws_subnet.database

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.key].id
}

# -----------------------------------------------------------------------------
# VPC Endpoint Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name}-vpc-endpoints-sg"
  description = "Allows HTTPS traffic from within the VPC to interface endpoints."
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from within the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-vpc-endpoints-sg"
    }
  )
}

# -----------------------------------------------------------------------------
# S3 Gateway Endpoint
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    values(aws_route_table.private)[*].id,
    values(aws_route_table.database)[*].id
  )

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-s3-endpoint"
    }
  )
}

# -----------------------------------------------------------------------------
# Systems Manager Interface Endpoints
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-ssm-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-ssm-messages-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-ec2-messages-endpoint"
    }
  )
}

# -----------------------------------------------------------------------------
# Amazon ECR Interface Endpoints
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-ecr-api-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-ecr-dkr-endpoint"
    }
  )
}
