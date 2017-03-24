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


function slack_msg() {
  if [ -n "$SLACK_TOKEN" ];then
    MSG="$1"
    curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$1"'"}' https://hooks.slack.com/services/$SLACK_TOKEN
  fi
}

function sql() {
  sqlite3 $DB "$@"
}

function filecount() {
  sql "SELECT COUNT(*) FROM files WHERE state=0"
}

function msg() {
  echo "$@"
  slack_msg "$@"
}

# vim: tabstop=2 shiftwidth=2 softtabstop=2 autoindent cindent smartindent
