#target: mars
FROM ubuntu:16.04
RUN adduser --uid 1000 user
RUN apt-get update
#RUN apt-get -y install libcurl3-gnutls libx11-6 x11-common libxext6 libxrender1 libxrandr2 libxt6 xauth x11-apps libasound2 pulseaudio x11-utils libxss1 mesa-utils-extra
RUN apt-get -y install libcurl3-gnutls x11-common xauth x11-apps libasound2 pulseaudio x11-utils libxss1 mesa-utils-extra libwayland-egl1 libwayland-cursor0
USER 1000
WORKDIR "/home/user/games/Surviving Mars"
CMD "./start.sh"
