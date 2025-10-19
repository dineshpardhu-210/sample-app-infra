#!/bin/bash
apt-get update -y
apt-get install -y openjdk-11-jre wget docker.io amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Jenkins setup
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y jenkins

# Proxy setup
SQUID_IP="${squid_ip}"
echo "HTTP_PROXY=http://${SQUID_IP}:3128/" >> /etc/environment
echo "HTTPS_PROXY=http://${SQUID_IP}:3128/" >> /etc/environment
echo "NO_PROXY=169.254.169.254,localhost,127.0.0.1" >> /etc/environment

echo "Acquire::http::Proxy \"http://${SQUID_IP}:3128/\";" > /etc/apt/apt.conf.d/01proxy
echo "Acquire::https::Proxy \"http://${SQUID_IP}:3128/\";" >> /etc/apt/apt.conf.d/01proxy

usermod -aG docker jenkins
systemctl enable docker jenkins
systemctl restart docker jenkins
