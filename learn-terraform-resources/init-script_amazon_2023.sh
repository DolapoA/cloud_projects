#!/bin/bash
# Updated for Amazon Linux 2023

# Update system packages
dnf update -y

# Remove unnecessary packages
dnf remove -y httpd httpd-tools

# Install necessary packages
dnf install -y httpd php mariadb105-server php-mysqlnd

# Start and enable httpd service
systemctl start httpd
systemctl enable httpd

# Add ec2-user to apache group and set permissions
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Download example web page
cd /var/www/html
curl -s http://169.254.169.254/latest/meta-data/instance-id -o index.html
curl -s https://raw.githubusercontent.com/hashicorp/learn-terramino/master/index.php -O

# Restart httpd to apply changes
systemctl restart httpd