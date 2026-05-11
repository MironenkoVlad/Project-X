data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Keys match the CFN logical-ID suffix (a=AZ0, b=AZ1, c=AZ2) and the Name tag convention.
  public_subnets = {
    "a" = { cidr = var.public_subnet_cidrs[0], az_index = 0 }
    "b" = { cidr = var.public_subnet_cidrs[1], az_index = 1 }
    "c" = { cidr = var.public_subnet_cidrs[2], az_index = 2 }
  }

  private_subnets = {
    "a" = { cidr = var.private_subnet_cidrs[0], az_index = 0 }
    "b" = { cidr = var.private_subnet_cidrs[1], az_index = 1 }
    "c" = { cidr = var.private_subnet_cidrs[2], az_index = 2 }
  }
}

# ── VPC ──────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "routebox-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "routebox-${var.environment}-igw"
  }
}

# ── Subnets ───────────────────────────────────────────────────────────────────

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = true

  tags = {
    Name = "routebox-${var.environment}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = false

  tags = {
    Name = "routebox-${var.environment}-private-${each.key}"
    Tier = "private"
  }
}

# ── NAT Gateway ───────────────────────────────────────────────────────────────
# Single NAT in public-a (cost optimisation, but a SPOF — see README).
# Originally three NAT gateways (one per AZ); collapsed to one and never restored.

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "routebox-${var.environment}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["a"].id

  tags = {
    Name = "routebox-${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# ── Route tables ──────────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "routebox-${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "routebox-${var.environment}-private-rt"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ── Security groups ───────────────────────────────────────────────────────────
# Cross-SG ingress rules for RDS are declared as separate
# aws_vpc_security_group_ingress_rule resources below to avoid cycles.

resource "aws_security_group" "alb" {
  name        = "routebox-${var.environment}-alb-sg"
  description = "Routebox public ALB. Open 80/443 from the internet."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from the internet (redirected to HTTPS at the listener)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "routebox-${var.environment}-alb-sg"
  }
}

resource "aws_security_group" "ecs_service" {
  name        = "routebox-${var.environment}-ecs-sg"
  description = "Routebox ECS service tasks. Inbound from the ALB only."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "All ports from ALB. Tightened per-service in the task SG would be better."
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  tags = {
    Name = "routebox-${var.environment}-ecs-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "routebox-${var.environment}-rds-sg"
  description = "Routebox RDS Postgres. 5432 from ECS tasks and Jenkins."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "routebox-${var.environment}-rds-sg"
  }
}

resource "aws_security_group" "jenkins" {
  name        = "routebox-${var.environment}-jenkins-sg"
  description = "Jenkins EC2. 8080 from VPC, 22 from bastion CIDR (TODO)."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Jenkins UI inside the VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # TODO: add ingress rule for SSH (port 22) from bastion CIDR once bastion is defined.

  tags = {
    Name = "routebox-${var.environment}-jenkins-sg"
  }
}

# RDS cross-SG ingress rules kept separate to avoid dependency cycles.

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Postgres from ECS tasks"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_service.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_jenkins" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Postgres from Jenkins (migrations + ad-hoc)"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.jenkins.id
}
