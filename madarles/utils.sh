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
