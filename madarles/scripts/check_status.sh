#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params

function check_services() {
  local SERVICES="smbd.service nmbd.service lighttpd.service"
  if systemctl is-active mnt-ADATA.mount;then
    systemctl start $SERVICES
  fi
}



check_services
if ! check_internet 5 5;then
  echo "Internet restart was required."
  systemctl restart wvdial.service 
else 
  echo "Internet is OK"
fi


