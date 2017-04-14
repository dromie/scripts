#!/bin/bash

LIVEPIDFILE=/tmp/live555.pid
PYPIDFILE=/tmp/streams.pid
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
#source ~pi/.params
source test_params
export DB SELF_IP RTSP_PORT LIVEPIDFILE

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
    sql "SELECT url from streams ORDER BY id"|xargs echo
    sleep 10 &
    echo $! >$LIVEPIDFILE
    wait `cat $LIVEPIDFILE`
done
