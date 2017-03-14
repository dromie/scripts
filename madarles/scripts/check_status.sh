#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params
RCFILE=/var/run/wvdial_retries


function check_services() {
  local SERVICES="smbd.service nmbd.service lighttpd.service"
  if systemctl is-active mnt-ADATA.mount;then
    systemctl start $SERVICES
  fi
}

set >/tmp/status.env

check_services
if ! check_internet 5 2;then
  RETRYCOUNT=0
  if [ -r $RCFILE ];then
    RETRYCOUNT=`cat $RCFILE`
  fi
  RETRYCOUNT=$[ $RETRYCOUNT + 1 ]
  if [ $RETRYCOUNT -gt 5 ];then
    echo "Reboot required.... Retry count reached 5"
    reboot
  else
    echo $RETRYCOUNT > $RCFILE
    echo "Internet restart was required. Retry count=$RETRYCOUNT"
    systemctl restart wvdial.service 
    systemctl restart emergency.timer
  fi
else 
  echo 0 > $RCFILE
  echo "Internet is OK"
  systemctl stop emergency.timer
fi


