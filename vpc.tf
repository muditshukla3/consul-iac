# creating vpc
resource "aws_vpc" "consul-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Consul"
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.consul-vpc.id 
    
    tags = {
      Name = "consul-igw"
    }
}

#create route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.consul-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Consul-Route-Table"
  }
}

## Public Subnets
resource "aws_subnet" "public" {
  count = var.vpc_public_subnet_count

  vpc_id                  = aws_vpc.consul-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.consul-vpc.cidr_block, 2, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    { "Name" = "${var.main_project_tag}-public-${data.aws_availability_zones.available.names[count.index]}" },
    { "Project" = var.main_project_tag },
    var.vpc_tags
  )
}

# Public Subnet Route Associations
resource "aws_route_table_association" "public" {
  count = var.vpc_public_subnet_count

  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public.id
}