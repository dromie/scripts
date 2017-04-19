#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`

if [ $UID != 0 ];then
  sudo $0 "$@"
  exit 0
fi

INSTALL_DIR=/home/pi/bin

pushd $self_dir


install_file() {
  local DIR=$1
  if [ ! -d "$DIR" ];then
    echo "Creating directory '$DIR'"
    mkdir -p "$DIR"
  fi
  shift
  while [ $# -gt 0 ];do
    echo "Installing $1 to '$DIR'..."
    cp $1 "$DIR"
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

pushd scripts
install_file $INSTALL_DIR utils.sh vpn.sh streams.py streams.sh 
install_file $INSTALL_DIR/static static/delete.png static/up.png static/down.png
install_file $INSTALL_DIR/templates templates/streams.html
popd

pushd systemd
install_service /etc/systemd/system/ vpn.service
install_service /etc/systemd/system/ stream.service
popd

systemctl daemon-reload
