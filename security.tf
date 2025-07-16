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
