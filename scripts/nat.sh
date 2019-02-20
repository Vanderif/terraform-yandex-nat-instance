#!/usr/bin/env bash
sudo yum update -y
sudo yum install iptables -y
sudo yum install -y iptables-services
sudo sh -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
sudo sysctl -p /etc/sysctl.conf
sudo service network restart
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo service iptables save