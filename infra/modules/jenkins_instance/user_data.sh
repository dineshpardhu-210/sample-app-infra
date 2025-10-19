#!/bin/bash
apt-get update -y
apt-get install -y openjdk-11-jre wget docker.io
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y jenkins
usermod -aG docker jenkins
systemctl enable --now docker jenkins
