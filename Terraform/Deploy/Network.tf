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