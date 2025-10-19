#!/bin/bash
# ---------------------------------------------
# Jenkins bootstrap script
# ---------------------------------------------
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk curl wget gnupg2

# Add Jenkins repo and key
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt-get update -y
sudo apt-get install -y jenkins

# Start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Output verification
echo "Jenkins installation completed successfully on $(hostname)" > /tmp/jenkins_install.log
