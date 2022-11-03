resource "aws_vpc" "dawid-ted" {
  cidr_block           = "10.0.0.0/26"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
  	Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
}

resource "aws_subnet" "dawid-ted" {
  vpc_id            = aws_vpc.dawid-ted.id
  cidr_block        = "10.0.0.0/28"
  availability_zone = var.av_zone
  tags = {
  	Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
}

resource "aws_internet_gateway" "dawid-ted" {
  vpc_id = aws_vpc.dawid-ted.id
  tags = {
  	Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
}

resource "aws_route_table" "dawid-ted" {
  vpc_id = aws_vpc.dawid-ted.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dawid-ted.id
  }
  tags = {
  	Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
}

resource "aws_route_table_association" "dawid-ted" {
  subnet_id      = aws_subnet.dawid-ted.id
  route_table_id = aws_route_table.dawid-ted.id
}
