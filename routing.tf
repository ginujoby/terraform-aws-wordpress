# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.website_vpc.id

  tags = {
    Name = "website-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.website_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Private App Route Tables
resource "aws_route_table" "private_app" {
  count  = 2
  vpc_id = aws_vpc.website_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private-app-rt-${count.index + 1}"
  }
}

# Private Data Route Tables
resource "aws_route_table" "private_data" {
  count  = 2
  vpc_id = aws_vpc.website_vpc.id

  tags = {
    Name = "private-data-rt-${count.index + 1}"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Association for Private App Subnet
resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Route Table Association for Private Data Subnet
resource "aws_route_table_association" "private_data" {
  count          = 2
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data[count.index].id
}
