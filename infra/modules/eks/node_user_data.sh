#!/bin/bash
# Configure system-wide proxy
SQUID_IP="${squid_ip}"

echo "HTTP_PROXY=http://${SQUID_IP}:3128/" >> /etc/environment
echo "HTTPS_PROXY=http://${SQUID_IP}:3128/" >> /etc/environment
echo "NO_PROXY=169.254.169.254,localhost,127.0.0.1,.cluster.local" >> /etc/environment

# Configure Docker proxy
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${SQUID_IP}:3128/"
Environment="HTTPS_PROXY=http://${SQUID_IP}:3128/"
Environment="NO_PROXY=169.254.169.254,localhost,127.0.0.1,.cluster.local"
EOF

# Restart Docker service
systemctl daemon-reload
systemctl restart docker
