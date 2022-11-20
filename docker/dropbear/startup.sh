#!/bin/ash
echo "Creating wg config..."
echo $WG_CONFIG|base64 -d >/etc/wireguard/wg0.conf
echo "wg up.."
wg-quick up wg0
wg show
echo 1 > /proc/sys/net/ipv4/ip_forward
exec dropbear -w -s -F -E -p 2222

