#!/bin/bash

function check_internet() {
  local DELAY=$1
  local RETRY=$2
  while [ $RETRY -gt 0 ];do
    if curl http://www.duckdns.org &>/dev/null ;then
      return 0
    fi
    RETRY=$[ $RETRY -1 ]
    sleep $DELAY
  done
  return 127
}

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
