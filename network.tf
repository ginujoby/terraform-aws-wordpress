# VPC and Networking
resource "aws_vpc" "website_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "website-vpc"
  }
}

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

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.website_vpc.id

  tags = {
    Name = "website-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = 2
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

# Security group for bastion host
resource "aws_security_group" "bastion" {
  name        = "bastion-ec2-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.website_vpc.id

  tags = {
    Name = "bastion-ec2-sg"
  }
}

# Allow inbound SSH access from current IP address
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = "${data.http.my_public_ip.response_body}/32"
}

# Allow all outbound traffic 
resource "aws_vpc_security_group_egress_rule" "bastion_egress" {
  security_group_id = aws_security_group.bastion.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.website_vpc.id

  tags = {
    Name = "alb-sg"
  }
}

# Allow inbound HTTP traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# Allow all outbound traffic 
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Security group for wordpress instances
resource "aws_security_group" "wordpress" {
  name        = "wordpress-ec2-sg"
  description = "Security group for WordPress instances"
  vpc_id      = aws_vpc.website_vpc.id

  tags = {
    Name = "wordpress-ec2-sg"
  }
}

# Allow inbound HTTP traffic from ALB security group
resource "aws_vpc_security_group_ingress_rule" "wordpress_http" {
  security_group_id = aws_security_group.wordpress.id

  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "wordpress_egress" {
  security_group_id = aws_security_group.wordpress.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Add SSH ingress rule to wordpress security group from bastion
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id            = aws_security_group.wordpress.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.website_vpc.id

  tags = {
    Name = "rds-sg"
  }
}

# Allow inbound MySQL traffic from wordpress security group
resource "aws_vpc_security_group_ingress_rule" "rds_mysql" {
  security_group_id            = aws_security_group.rds.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.wordpress.id
}
