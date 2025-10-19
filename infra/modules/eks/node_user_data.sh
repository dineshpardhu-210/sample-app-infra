#!/bin/bash
set -ex

# Install and start SSM Agent
yum update -y
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Set Squid proxy IP from Terraform variable
SQUID_IP="${squid_ip}"

# Configure environment-wide proxy settings
cat <<EOF > /etc/profile.d/proxy.sh
export http_proxy=http://${squid_ip}:3128
export https_proxy=http://${squid_ip}:3128
export no_proxy=169.254.169.254,localhost,127.0.0.1
EOF

chmod +x /etc/profile.d/proxy.sh

# Configure Docker to use the proxy
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${squid_ip}:3128"
Environment="HTTPS_PROXY=http://${squid_ip}:3128"
Environment="NO_PROXY=169.254.169.254,localhost,127.0.0.1"
EOF

systemctl daemon-reload
systemctl restart docker

echo "EKS node configured with Squid proxy at ${squid_ip}"
