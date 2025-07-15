# Data source for AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to get my public IP
data "http" "my_public_ip" {
  url = "https://api.ipify.org"
}

# Data source to get the latest Amazon Linux 2 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}
