#!/bin/bash
apt-get update
apt-get install -y mysql-client
iptables -A POSTROUTING -t nat -s 10.0.0.0/23 -j MASQUERADE
bash -c 'echo "1" > /proc/sys/net/ipv4/ip_forward'
sysctl -w net.ipv4.ip_forward=1