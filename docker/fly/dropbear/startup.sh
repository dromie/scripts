#!/bin/ash -x
WG_HOSTS=/tmp/wghost
CONF=/etc/wireguard/wg0.conf
WG_INTERFACES=""
if [ -n "$WG_CONFIG" ]; then
  echo "Creating wg config..."
  echo $WG_CONFIG|base64 -d >$CONF
  echo "wg up.."
  wg-quick up wg0
  wg show
  WG_INTERFACES="wg0"
  cat $CONF |grep '[Peer].*#host:'|cut -f 2 -d:|sed 's/^[ ]*//g' >>$WG_HOSTS
  echo 1 > /proc/sys/net/ipv4/ip_forward
fi
if [ -n $DNSMASQ_CONFIG ]; then
  echo "Creating dnsmasq config..."
  echo $DNSMASQ_CONFIG|base64 -d|tar xvz -C /etc/dnsmasq.d
  dnsmasq -d --addn-hosts=$WG_HOSTS ${WG_INTERFACES:+-i $WG_INTERFACES} &
fi
exec dropbear -w -s -F -E -p 2222

