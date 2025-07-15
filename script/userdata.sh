#!/bin/bash

# WordPress installation and configuration script

# Update system packages
sudo yum update -y

# Install Apache web server
sudo yum install -y httpd

# Install PHP, and necessary tools
sudo amazon-linux-extras install -y php8.2
sudo yum clean metadata

# Start and Enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Download and install WordPress
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .
sudo rm -R wordpress
sudo rm latest.tar.gz

# Making changes to the wp-config.php file, setting the DB name
sudo cp ./wp-config-sample.php ./wp-config.php 
sudo sed -i "s/'database_name_here'/'${db_name}'/g" wp-config.php
sudo sed -i "s/'username_here'/'${db_username}'/g" wp-config.php
sudo sed -i "s/'password_here'/'${db_password}'/g" wp-config.php
sudo sed -i "s/'localhost'/'${db_endpoint}'/g" wp-config.php

# Grant permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/
sudo chmod 2775 /var/www/
sudo find /var/www/ -type d -exec chmod 2775 {} \;
sudo find /var/www/ -type f -exec chmod 0664 {} \;

