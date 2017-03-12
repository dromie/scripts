#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params

if [ $UID != 0 ];then
  sudo $0 "$@"
  exit 0
fi

INSTALL_DIR=/home/pi/bin

pushd $self_dir


install_file() {
  local DIR=$1
  shift
  while [ $# -gt 0 ];do
    echo "Installing $1 to $DIR..."
    cp $1 $DIR
    shift
  done
}

install_service() {
  install_file "$@"
  shift
  while [ $# -gt 0 ];do
    echo "Enabling $1 systed service"
    systemctl enable $1 
    shift
  done
}

install_file $INSTALL_DIR check_status.sh duckdns findsort.py iptables.sh upload utils.sh vpn.sh wvdial.sh
install_file /etc iptables.config wvdial.conf

pushd systemd
install_service /etc/systemd/system/ iptables.service mnt-ADATA.mount status.service status.timer vpn.service wvdial.service
install_file /etc/systemd/system/smbd.service.d/ smbd.service.d/drop.conf

popd
pushd udev
install_file /etc/udev/rules.d 90-3g.rules
systemctl daemon-reload
