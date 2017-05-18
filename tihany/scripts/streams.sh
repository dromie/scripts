#!/bin/bash

LIVEPIDFILE=/tmp/live555.pid
LIVEOUT=/tmp/live.out
PYPIDFILE=/tmp/streams.pid
PYOUT=/tmp/py.out
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params
#source test_params
SELF_IP=`ip -o -4 address show $DEVICE |sed 's#.*inet \([^ /]*\) \?/\?.*#\1#'`
export DB SELF_IP RTSP_PORT LIVEPIDFILE LIVEOUT
msg "$HOST Stream proxy service restarted. Ethernet IP: $SELF_IP"
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

python3 $self_dir/streams.py &>$PYOUT &
echo $! >$PYPIDFILE

while [ 0 ];do
    killall `basename $LIVEBIN`
    if [ `sql "SELECT url from streams ORDER BY id"|wc -l` -gt 0 ];then
        echo -n "$LIVEBIN" >$LIVEOUT
        sql "SELECT url from streams ORDER BY id"|xargs  >>$LIVEOUT
        sql "SELECT url from streams ORDER BY id"|xargs $LIVEBIN &>>$LIVEOUT &
        sleep 5
        pidof `basename $LIVEBIN` >$LIVEPIDFILE
    else
        echo "No streams defined." >$LIVEOUT
        sleep 3600 &
        echo $! >$LIVEPIDFILE
    fi
    wait_for_pid `cat $LIVEPIDFILE`
done
