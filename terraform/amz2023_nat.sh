#!/bin/bash
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables
sysctl -w net.ipv4.ip_forward=1
iptables -F
/sbin/iptables -t nat -A POSTROUTING -o $(cut -d' ' -f1 <<<$(echo $(ls /sys/class/net))) -j MASQUERADE
service iptables save