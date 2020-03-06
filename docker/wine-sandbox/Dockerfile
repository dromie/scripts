#target: wine-sandbox

FROM build-essential
RUN dpkg --add-architecture i386 && \
  curl https://dl.winehq.org/wine-builds/winehq.key|apt-key add - && \
  curl https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key|apt-key add - 
RUN echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' >/etc/apt/sources.list.d/winehq.list && \
  echo 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./' >/etc/apt/sources.list.d/suse-winehq.list && \
  apt-get update
RUN apt-get install -y --install-recommends winehq-stable winetricks
RUN for i in `seq 0 5`;do adduser user$i audio;adduser user$i video;done

