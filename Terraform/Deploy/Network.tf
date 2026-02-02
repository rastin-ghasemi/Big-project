##########################
# Network Infrastructure #
##########################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "main"
    Environment = "demo_environ"
    region      = data.aws_region.current.name
    Terraform   = "true"
  }
}
#########################################################
# Internet Gataway needed for inbound access to the ALB #
#########################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.Prefix}-main"
  }
}
###########################################
# Public Subnet for LB Public Access #
###########################################
resource "aws_subnet" "public_subnets-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a"
  tags = {
    Name = "${local.Prefix}-Public-a"
  }
}

########################################
# Create Route Tables and Associations #
########################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name      = "${local.Prefix}-Public-a"
    Terraform = "true"
  }
}
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public_subnets-a.id
  route_table_id = aws_route_table.public_route_table.id
}


###########################################
# Private Subnet for Internet Access #
###########################################
resource "aws_subnet" "Private-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a"
  tags = {
    Name = "${local.Prefix}-Private-a"
  }
}
##################################################################################################################################
########################################
# EndPonint to allow ECS to access ECR #
########################################
resource "aws_security_group" "endpoint_access" {
  name        = "${local.Prefix}-endpoint-access"
  vpc_id      = aws_vpc.main.id
  description = "Access to Endpoint."
  ingress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
}
resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.Private-a.id]
  security_group_ids  = [aws_security_group.endpoint_access.id]
  tags = {
    Name = "${local.Prefix}-ecr-endpoint"
  }

}
resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.Private-a.id]
  security_group_ids  = [aws_security_group.endpoint_access.id]
  tags = {
    Name = "${local.Prefix}-dkr-endpoint"
  }

}
resource "aws_vpc_endpoint" "cloudWatch_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.Private-a.id]
  security_group_ids  = [aws_security_group.endpoint_access.id]
  tags = {
    Name = "${local.Prefix}-CloudWatch-endpoint"
  }

}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmassages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.Private-a.id]
  security_group_ids  = [aws_security_group.endpoint_access.id]
  tags = {
    Name = "${local.Prefix}-ssmmassages-endpoint"
  }


}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_vpc.main.default_route_table_id
  ]
  tags = {
    Name = "${local.Prefix}-S3-Endpoint"

  }

}