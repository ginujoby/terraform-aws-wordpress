# Bastion host public IP
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# Load Balancer DNS name
output "lb_dns_name" {
  value = aws_lb.wordpress.dns_name
}

# DB endpoint
output "rds_endpoint" {
  value = aws_db_instance.wordpress.endpoint
}

