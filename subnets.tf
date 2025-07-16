# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.website_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.website_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-app-subnet-${count.index + 1}"
  }
}

# Private Data Subnets
resource "aws_subnet" "private_data" {
  count             = 2
  vpc_id            = aws_vpc.website_vpc.id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-data-subnet-${count.index + 1}"
  }
}
