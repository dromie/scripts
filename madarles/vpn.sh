#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh
source ~pi/.params


SSH="/usr/bin/ssh -o StrictHostKeyChecking=no sleeper@$SERVER -p 2222 -i /home/pi/.ssh/id_rsa"
port=`echo $HOST|$SSH "getconsole $HOST"`
exec $SSH -f -n -R$port:localhost:2222 "sleep 3600"


