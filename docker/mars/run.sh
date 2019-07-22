#!/bin/bash
self_dir=`dirname "$(readlink -f $0)"`
docker run -it --rm \
  -v $HOME/GOG\ Games/:/home/user/games \
  -v $HOME/.local/share/Surviving\ Mars:/home/user/.local/share/Surviving\ Mars \
  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device /dev/dri \
  --device /dev/snd \
mars "$@"
