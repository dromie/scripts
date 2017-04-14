#!/bin/bash

function slack_msg() {
  if [ -n "$SLACK_TOKEN" ];then
    MSG="$1"
    curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$1"'"}' https://hooks.slack.com/services/$SLACK_TOKEN
  fi
}

function sql() {
  sqlite3 $DB "$@"
}

function msg() {
  echo "$@"
  slack_msg "$@"
}

# vim: tabstop=2 shiftwidth=2 softtabstop=2 autoindent cindent smartindent
