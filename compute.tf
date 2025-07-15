# Key pair for SSH access
resource "aws_key_pair" "bastion" {
  key_name   = "bastion-key"
  public_key = file(var.ssh_pub_key)
}

# EC2 instance for bastion host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = true

  tags = {
    Name = "wordpress-bastion"
  }
}
