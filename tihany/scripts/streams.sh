#!/bin/bash

LIVEPIDFILE=/tmp/live555.pid
LIVEOUT=/tmp/live.out
PYPIDFILE=/tmp/streams.pid
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
#source ~pi/.params
source test_params
SELF_IP=`ip -o -4 address show $DEVICE |sed 's#.*inet \([^ /]*\) \?/\?.*#\1#'`
export DB SELF_IP RTSP_PORT LIVEPIDFILE LIVEOUT

stopall() {
    kill `cat $PYPIDFILE`
    kill `cat $LIVEPIDFILE`
    exit -1
}

trap stopall INT
trap stopall TERM

if [ ! -f $DB ];then
  sql "create table streams (id INTEGER,url TEXT)"
fi

python3 $self_dir/streams.py &
echo $! >$PYPIDFILE

while [ 0 ];do
    sql "SELECT url from streams ORDER BY id"|xargs $LIVEBIN &>$LIVEOUT &
    echo $! >$LIVEPIDFILE
    wait `cat $LIVEPIDFILE`
done
