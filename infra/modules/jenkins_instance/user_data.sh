#!/bin/bash
apt-get update -y
apt-get install -y openjdk-11-jre wget docker.io
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y jenkins

# Configure proxy
SQUID_IP="${squid_ip}"
echo "HTTP_PROXY=http://${SQUID_IP}:3128/" >> /etc/environment
echo "HTTPS_PROXY=http://${SQUID_IP}:3128/" >> /etc/environment
echo "NO_PROXY=169.254.169.254,localhost,127.0.0.1" >> /etc/environment

# Apply proxy for apt and Jenkins
echo "Acquire::http::Proxy \"http://${SQUID_IP}:3128/\";" > /etc/apt/apt.conf.d/01proxy
echo "Acquire::https::Proxy \"http://${SQUID_IP}:3128/\";" >> /etc/apt/apt.conf.d/01proxy

# Restart Jenkins and Docker
usermod -aG docker jenkins
systemctl enable docker jenkins
systemctl restart docker jenkins
