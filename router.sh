#!/bin/bash
LAN=eth0
WAN=wlan0
ip link set $LAN up
ip addr add 192.168.1.1/24 dev $LAN
echo 1 >/proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
dnsmasq -F 192.168.1.32,192.168.1.64 -d --interface $LAN --log-dhcp --port 0 --dhcp-option=option:dns-server,8.8.8.8

