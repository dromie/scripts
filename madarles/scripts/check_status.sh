#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params
RCFILE=/var/run/wvdial_retries
REBOOT_LIMIT=100

function check_services() {
  local SERVICES="smbd.service nmbd.service lighttpd.service"
  if systemctl is-active mnt-ADATA.mount;then
    systemctl start $SERVICES
  fi
}


check_services
RETRYCOUNT=0
if [ -r $RCFILE ];then
  RETRYCOUNT=`cat $RCFILE`
fi
if ! check_internet 5 2;then
  RETRYCOUNT=$[ $RETRYCOUNT + 1 ]
  if [ $RETRYCOUNT -gt $REBOOT_LIMIT ];then
    echo "Reboot required.... Retry count reached $REBOOT_LIMIT"
    reboot
  else
    echo $RETRYCOUNT > $RCFILE
    echo "Internet restart was required. Retry count=$RETRYCOUNT"
    systemctl restart wvdial.service 
    systemctl restart emergency.timer
  fi
else 
  if [ $RETRYCOUNT -gt 0 ];then
    MYIP=`ip -o -4 address show dev ppp0|sed 's#.*inet \([^ ]*\) .*#\1#'`
    slack_msg "Back online. New IP=$MYIP"
  fi
  echo 0 > $RCFILE
  echo "Internet is OK"
  systemctl stop emergency.timer
fi
DNSIP=`dig +short $HOST.duckdns.org`
MYIP=`ip -o -4 address show dev ppp0|sed 's#.*inet \([^ ]*\) .*#\1#'`
if [ "$DNSIP" != "$MYIP" ];then
  ${self_dir}/duckdns
  slack_msg "Back online. New IP=$MYIP"
fi

# vim: tabstop=2 shiftwidth=2 softtabstop=2 autoindent cindent smartindent
