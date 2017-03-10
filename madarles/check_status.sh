#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params
exec 3>/tmp/status.log
exec >&3
exec 2>&3


function reconnect() {
  if ! check_internet 5 5;then
    RETRY=5
    while [ $RETRY -gt 0 ];do
      if [ -r /dev/gsmmodem ];then
        ifdown ppp0
        sleep 5
        ifup ppp0
      sleep 5
    fi
    if check_internet 5 5;then
      echo "Internet is back online...."
      return 0
    fi
  done
  return 1
  fi
  echo "Internet still working..."
  return 0
}

function vpn() {
  local VPNPID=/tmp/vpn.pid
  local SSH="/usr/bin/ssh -o StrictHostKeyChecking=no sleeper@$SERVER -p 2222 -i /home/pi/.ssh/id_rsa"
  [ -r $VPNPID ] && kill -9 `cat $VPNPID`
  local port=`echo $HOST|$SSH "getconsole $HOST"`
  nohup $SSH -R$port:localhost:2222 "sleep 3600" </dev/null &>/dev/null & 
  echo $! >$VPNPID
}

function check_services() {
  local SERVICES="smbd.service nmbd.service"
  if systemctl is-active mnt-ADATA.mount;then
    systemctl start $SERVICES
  fi
}

check_services
reconnect && vpn


